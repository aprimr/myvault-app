import 'package:app/core/service_locator.dart';
import 'package:app/services/setting.dart';
import 'package:app/widgets/input_field.dart';
import 'package:app/widgets/primary_button.dart';
import 'package:app/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:app/widgets/app_loader.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool isLoading = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  late final SettingService settingService;
  final _formKey = GlobalKey<FormState>();

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    settingService = SettingService(apiClient);
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await settingService.changePassword(
        currentPassword: currentPasswordController.text,
        newPassword: newPasswordController.text,
        confirmPassword: confirmPasswordController.text,
      );

      if (!mounted) return;

      setState(() => isLoading = false);

      AppSnackbar.show(
        context,
        message: "Password updated successfully",
        isError: false,
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);

      AppSnackbar.show(
        context,
        message: "Failed to update password",
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
                // AppBar
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
                        "Change Password",
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
                            "Choose a strong password with at least one capital letter, numbers, and symbols to ensure total security.",
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              color: colorScheme.onSurface.withAlpha(130),
                            ),
                          ),
                        ),

                        // Current Password Field
                        InputField(
                          controller: currentPasswordController,
                          label: "Current Password",
                          icon: HugeIcons.strokeRoundedLockPassword,
                          obscure: _obscureCurrentPassword,
                          suffixIcon: GestureDetector(
                            onTap: () => setState(
                              () => _obscureCurrentPassword =
                                  !_obscureCurrentPassword,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(13),
                              child: HugeIcon(
                                icon: _obscureCurrentPassword
                                    ? HugeIcons.strokeRoundedView
                                    : HugeIcons.strokeRoundedViewOff,
                                color: colorScheme.onSurface.withAlpha(120),
                                size: 20,
                              ),
                            ),
                          ),
                          validator: (v) => v!.isEmpty
                              ? "Current password is required"
                              : null,
                        ),

                        const SizedBox(height: 14),

                        // New Password Field with custom regex requirements
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

                        // Confirm Password Field
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

                        PrimaryButton(text: "Update Password", onTap: _submit),
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
            child: AppLoader(message: "Updating password..."),
          ),
      ],
    );
  }
}
