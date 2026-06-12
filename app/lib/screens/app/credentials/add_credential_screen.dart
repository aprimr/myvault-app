import 'package:app/core/service_locator.dart';
import 'package:app/services/credential.dart';
import 'package:app/widgets/input_field.dart';
import 'package:app/widgets/primary_button.dart';
import 'package:app/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:app/widgets/app_loader.dart';

class AddCredentialScreen extends StatefulWidget {
  const AddCredentialScreen({super.key});

  @override
  State<AddCredentialScreen> createState() => _AddCredentialScreenState();
}

class _AddCredentialScreenState extends State<AddCredentialScreen> {
  bool isLoading = false;
  bool _obscurePassword = true;

  late final CredentialService credentialService;
  final _formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final urlController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();

    credentialService = CredentialService(apiClient);
  }

  @override
  void dispose() {
    titleController.dispose();
    emailController.dispose();
    passwordController.dispose();
    urlController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await credentialService.addCredential(
        title: titleController.text.trim(),
        emailOrUsername: emailController.text.trim(),
        password: passwordController.text.trim(),
        loginUrl: urlController.text.trim(),
        description: descriptionController.text.trim(),
      );

      if (!mounted) return;

      setState(() => isLoading = false);

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);

      AppSnackbar.show(
        context,
        message: "Failed to save credential",
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
                        "Add Credential",
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
                            "Your credentials are encrypted before being stored in the database to keep your data protected.",
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              color: colorScheme.onSurface.withAlpha(130),
                            ),
                          ),
                        ),

                        InputField(
                          controller: titleController,
                          label: "Title",
                          icon: HugeIcons.strokeRoundedBookmark01,
                          validator: (v) =>
                              v!.isEmpty ? "Title is required" : null,
                        ),

                        const SizedBox(height: 14),

                        InputField(
                          controller: emailController,
                          label: "Email / Username",
                          icon: HugeIcons.strokeRoundedAt,
                          keyboardType: TextInputType.text,
                          validator: (v) => v!.isEmpty
                              ? "Email or username is required"
                              : null,
                        ),

                        const SizedBox(height: 14),

                        InputField(
                          controller: passwordController,
                          label: "Password",
                          icon: HugeIcons.strokeRoundedLockPassword,
                          obscure: _obscurePassword,
                          suffixIcon: GestureDetector(
                            onTap: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(13),
                              child: HugeIcon(
                                icon: _obscurePassword
                                    ? HugeIcons.strokeRoundedView
                                    : HugeIcons.strokeRoundedViewOff,
                                color: colorScheme.onSurface.withAlpha(120),
                                size: 20,
                              ),
                            ),
                          ),
                          validator: (v) =>
                              v!.isEmpty ? "Password is required" : null,
                        ),

                        const SizedBox(height: 14),

                        InputField(
                          controller: urlController,
                          label: "Login URL (optional)",
                          icon: HugeIcons.strokeRoundedLink01,
                          keyboardType: TextInputType.url,
                        ),

                        const SizedBox(height: 14),

                        InputField(
                          controller: descriptionController,
                          label: "Description (optional)",
                          icon: HugeIcons.strokeRoundedNote01,
                          keyboardType: TextInputType.text,
                        ),

                        const SizedBox(height: 24),

                        PrimaryButton(text: "Save Credential", onTap: _submit),
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
            child: AppLoader(message: "Saving credential..."),
          ),
      ],
    );
  }
}
