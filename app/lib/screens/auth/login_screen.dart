import 'package:app/core/app.dart';
import 'package:app/core/routes.dart';
import 'package:app/widgets/snackbar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final authService = App.authService;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _hidePassword = !_hidePassword;
    });
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

                  // Login to My Vault
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Login to',
                        style: GoogleFonts.stackSansNotch(
                          fontSize: 38,
                          fontWeight: FontWeight.w500,
                          height: 1.14,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'My Vault',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          height: 1.14,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Email
                        Row(
                          children: [
                            Text(
                              'Email',
                              style: GoogleFonts.nunitoSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface.withAlpha(200),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          cursorColor: colorScheme.primary,
                          style: GoogleFonts.inter(fontSize: 15),

                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Email is required";
                            }
                            if (!value.contains("@") || !value.contains(".")) {
                              return "Enter valid email";
                            }
                            return null;
                          },

                          decoration: InputDecoration(
                            hintText: 'john@gmail.com',
                            hintStyle: GoogleFonts.poppins(
                              color: colorScheme.onSecondary.withAlpha(100),
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
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Password
                        Row(
                          children: [
                            Text(
                              'Password',
                              style: GoogleFonts.nunitoSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface.withAlpha(200),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: passwordController,
                          keyboardType: TextInputType.visiblePassword,
                          cursorColor: colorScheme.primary,
                          style: GoogleFonts.inter(fontSize: 15),
                          obscureText: _hidePassword,
                          enableSuggestions: false,
                          autocorrect: false,

                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Password is required";
                            }
                            if (value.length < 8) {
                              return "Password must be atleast 8 characters";
                            }
                            return null;
                          },

                          decoration: InputDecoration(
                            hintText: '••••••••',
                            suffixIcon: IconButton(
                              onPressed: _togglePasswordVisibility,
                              icon: HugeIcon(
                                icon: !_hidePassword
                                    ? HugeIcons.strokeRoundedViewOffSlash
                                    : HugeIcons.strokeRoundedView,
                                size: 22,
                                color: colorScheme.onSurface,
                              ),
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                            ),
                            hintStyle: GoogleFonts.poppins(
                              color: colorScheme.onSecondary.withAlpha(100),
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
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Forgot password
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.forgotPasswordRoute,
                                );
                              },
                              child: Text(
                                "Forgot password",
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Login Button
                        SizedBox(
                          height: 54,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _handleLogin,
                            style: ButtonStyle(
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
                                    'Login',
                                    style: GoogleFonts.stackSansNotch(
                                      fontSize: 22,
                                      color: colorScheme.surface,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(bottom: 28),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.signupRoute);
              },
              child: Text(
                "Signup",
                style: GoogleFonts.poppins(
                  color: colorScheme.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            SizedBox(width: 10),
            Text(
              "•",
              style: TextStyle(
                fontSize: 24,
                color: colorScheme.onSurface.withAlpha(150),
              ),
            ),
            SizedBox(width: 10),

            GestureDetector(
              onTap: () {},
              child: Text(
                "Verify Account",
                style: GoogleFonts.poppins(
                  color: colorScheme.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      await authService.login(emailController.text, passwordController.text);

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.homeRoute,
        (route) => false,
      );
    } catch (e) {
      String message = "Something went wrong";
      if (e is DioException) {
        message = e.response?.data["message"];
      }
      AppSnackbar.show(context, message: message, isError: true);
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }
}
