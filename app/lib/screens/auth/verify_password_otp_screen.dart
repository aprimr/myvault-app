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

class VerifyForgotPasswordScreen extends StatefulWidget {
  final String email;
  final String uid;

  const VerifyForgotPasswordScreen({
    super.key,
    required this.email,
    required this.uid,
  });

  @override
  State<VerifyForgotPasswordScreen> createState() =>
      _VerifyForgotPasswordScreenState();
}

class _VerifyForgotPasswordScreenState
    extends State<VerifyForgotPasswordScreen> {
  bool isLoading = false;
  late final SettingService settingService;
  final _formKey = GlobalKey<FormState>();
  final otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    settingService = SettingService(apiClient);
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final Map<String, dynamic> response = await settingService
          .verifyForgotPasswordOtp(
            uid: widget.uid,
            otp: otpController.text.trim(),
          );

      String serverOtpId = response['otp_id'] ?? '';
      String serverUid = response['uid'] ?? widget.uid;

      if (!mounted) return;
      setState(() => isLoading = false);

      AppSnackbar.show(
        context,
        message: "Code verified successfully",
        isError: false,
      );

      Navigator.pushNamed(
        context,
        AppRoutes.setNewPasswordRoute,
        arguments: {"uid": serverUid, "otpId": serverOtpId},
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);

      AppSnackbar.show(
        context,
        message: "Invalid or expired verification code",
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
                        "Verify OTP",
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
                            "Please enter the verification code sent to ${widget.email} to reset the password.",
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              color: colorScheme.onSurface.withAlpha(130),
                            ),
                          ),
                        ),
                        InputField(
                          controller: otpController,
                          label: "Verification Code",
                          icon: HugeIcons.strokeRoundedForgotPassword,
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return "Code is required";
                            }
                            if (v.length < 6) return "Code must be 6 digits";
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        PrimaryButton(text: "Verify Code", onTap: _submit),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isLoading)
          const Positioned.fill(child: AppLoader(message: "Validating otp...")),
      ],
    );
  }
}
