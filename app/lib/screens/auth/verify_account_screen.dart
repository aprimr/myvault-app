import 'package:app/core/app.dart';
import 'package:app/core/routes.dart';
import 'package:app/widgets/snackbar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

class VerifyAccountScreen extends StatefulWidget {
  final String email;
  final String uid;
  const VerifyAccountScreen({
    super.key,
    required this.email,
    required this.uid,
  });

  @override
  State<VerifyAccountScreen> createState() => _VerifyAccountScreenState();
}

class _VerifyAccountScreenState extends State<VerifyAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final authService = App.authService;
  final codeController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    try {
      setState(() => isLoading = true);

      await authService.verifyAccount(widget.uid, codeController.text.trim());

      if (!mounted) return;
      AppSnackbar.show(context, message: "Account verified successfully");

      Navigator.pushNamed(context, AppRoutes.loginRoute);
    } catch (e) {
      String message = "Something went wrong";
      if (e is DioException) {
        message = e.response?.data["message"] ?? "Something went wrong";
      }
      if (mounted) AppSnackbar.show(context, message: message, isError: true);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedSafeBox,
                        color: colorScheme.primary,
                        size: 36,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Verify your account
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verify your',
                        style: GoogleFonts.stackSansNotch(
                          fontSize: 38,
                          fontWeight: FontWeight.w500,
                          height: 1.14,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Account',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          height: 1.14,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Subtitle
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.nunitoSans(
                        fontSize: 14,
                        color: colorScheme.onSurface.withAlpha(160),
                        height: 1.5,
                      ),
                      children: [
                        const TextSpan(text: "Enter the code we sent to "),
                        TextSpan(
                          text: widget.email,
                          style: GoogleFonts.nunitoSans(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface.withAlpha(220),
                          ),
                        ),
                        const TextSpan(text: " to verify your account."),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Label
                        Text(
                          'Verification Code',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface.withAlpha(200),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: codeController,
                          keyboardType: TextInputType.number,
                          cursorColor: colorScheme.primary,
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            letterSpacing: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          maxLength: 6,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Code is required";
                            }
                            if (value.trim().length < 6) {
                              return "Enter the full 6-digit code";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: '------',
                            counterText: '',
                            hintStyle: GoogleFonts.inter(
                              color: colorScheme.onSecondary.withAlpha(100),
                              letterSpacing: 14,
                              fontSize: 22,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(
                                color: colorScheme.onSurface.withAlpha(40),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(
                                color: colorScheme.primary,
                                width: 1.6,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(color: colorScheme.error),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(
                                color: colorScheme.error,
                                width: 1.6,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Verify button
                        SizedBox(
                          height: 54,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _handleVerify,
                            style: const ButtonStyle(
                              elevation: WidgetStatePropertyAll(0),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Verify',
                                    style: GoogleFonts.stackSansNotch(
                                      fontSize: 22,
                                      color: colorScheme.surface,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
