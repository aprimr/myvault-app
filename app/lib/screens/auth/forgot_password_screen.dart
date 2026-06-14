import 'package:app/core/routes.dart';
import 'package:app/core/service_locator.dart';
import 'package:app/services/setting.dart';
import 'package:app/widgets/input_field.dart';
import 'package:app/widgets/primary_button.dart';
import 'package:app/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:app/widgets/app_loader.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool isLoading = false;
  late final SettingService settingService;
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    settingService = SettingService(apiClient);
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final email = emailController.text.trim();
      final data = await settingService.forgotPassword(email: email);

      final String uid = data['uid'] ?? '';

      if (!mounted) return;
      setState(() => isLoading = false);

      AppSnackbar.show(
        context,
        message: "Recovery code sent to your email",
        isError: false,
      );

      Navigator.pushNamed(
        context,
        AppRoutes.verifyForgotPasswordRoute,
        arguments: {"email": email, "uid": uid},
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);

      AppSnackbar.show(
        context,
        message: "Failed to request password reset link",
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Scaffold(
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedArrowLeft01,
                          color: colorScheme.onSurface,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        "Forgot Password",
                        style: GoogleFonts.outfit(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 100),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 22, 26),
                          child: Text(
                            "Enter the email address associated with your account. We will send you a 6-digit confirmation code to verify your identity.",
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              color: colorScheme.onSurface.withAlpha(130),
                            ),
                          ),
                        ),
                        InputField(
                          controller: emailController,
                          label: "Email Address",
                          icon: HugeIcons.strokeRoundedAt,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return "Email is required";
                            }
                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(v)) {
                              return "Please enter a valid email address";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        PrimaryButton(text: "Continue", onTap: _submit),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isLoading)
          const Positioned.fill(
            child: AppLoader(message: "Sending recovery code..."),
          ),
      ],
    );
  }
}
