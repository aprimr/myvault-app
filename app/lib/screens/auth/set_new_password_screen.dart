import 'package:app/core/service_locator.dart';
import 'package:app/services/setting.dart';
import 'package:app/widgets/input_field.dart';
import 'package:app/widgets/primary_button.dart';
import 'package:app/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:app/widgets/app_loader.dart';

class SetNewPasswordScreen extends StatefulWidget {
  final String uid;
  final String otpId;

  const SetNewPasswordScreen({
    super.key,
    required this.uid,
    required this.otpId,
  });

  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  bool isLoading = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  late final SettingService settingService;
  final _formKey = GlobalKey<FormState>();

  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    settingService = SettingService(apiClient);
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await settingService.setNewPassword(
        uid: widget.uid,
        otpId: widget.otpId,
        newPassword: newPasswordController.text,
      );

      if (!mounted) return;
      setState(() => isLoading = false);

      AppSnackbar.show(
        context,
        message: "Password reset successful",
        isError: false,
      );

      int count = 0;
      Navigator.popUntil(context, (route) => count++ >= 3);
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);

      AppSnackbar.show(
        context,
        message: "Failed to set a new password session",
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
                        "Reset Password",
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
                            "Choose a strong password with at least one letter, digits, and symbols to ensure total security.",
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              color: colorScheme.onSurface.withAlpha(130),
                            ),
                          ),
                        ),
                        InputField(
                          controller: newPasswordController,
                          label: "New Password",
                          icon: HugeIcons.strokeRoundedLockPassword,
                          obscure: _obscureNewPassword,
                          suffixIcon: GestureDetector(
                            onTap: () => setState(
                              () => _obscureNewPassword = !_obscureNewPassword,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(13),
                              child: HugeIcon(
                                icon: _obscureNewPassword
                                    ? HugeIcons.strokeRoundedView
                                    : HugeIcons.strokeRoundedViewOff,
                                color: colorScheme.onSurface.withAlpha(120),
                                size: 20,
                              ),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return "New password is required";
                            }
                            if (v.length < 8) {
                              return "Password must be at least 8 characters";
                            }
                            if (!RegExp(r'[a-zA-Z]').hasMatch(v)) {
                              return "Password must contain at least 1 letter";
                            }
                            if (!RegExp(r'[0-9]').hasMatch(v)) {
                              return "Password must contain at least 1 digit";
                            }
                            if (!RegExp(
                              r'[!@#$%^&*(),.?":{}|<>]',
                            ).hasMatch(v)) {
                              return "Password must contain at least 1 special character";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        InputField(
                          controller: confirmPasswordController,
                          label: "Confirm New Password",
                          icon: HugeIcons.strokeRoundedLockPassword,
                          obscure: _obscureConfirmPassword,
                          suffixIcon: GestureDetector(
                            onTap: () => setState(
                              () => _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(13),
                              child: HugeIcon(
                                icon: _obscureConfirmPassword
                                    ? HugeIcons.strokeRoundedView
                                    : HugeIcons.strokeRoundedViewOff,
                                color: colorScheme.onSurface.withAlpha(120),
                                size: 20,
                              ),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return "Please confirm your password";
                            }
                            if (v != newPasswordController.text) {
                              return "Passwords do not match";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        PrimaryButton(
                          text: "Save New Password",
                          onTap: _submit,
                        ),
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
            child: AppLoader(message: "Resetting password..."),
          ),
      ],
    );
  }
}
