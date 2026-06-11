import 'package:app/widgets/hold_to_delete_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:app/widgets/app_loader.dart';
import 'package:app/services/credential.dart';
import 'package:app/core/api.dart';

class ViewCredentialScreen extends StatefulWidget {
  final String id;

  const ViewCredentialScreen({super.key, required this.id});

  @override
  State<ViewCredentialScreen> createState() => _ViewCredentialScreenState();
}

class _ViewCredentialScreenState extends State<ViewCredentialScreen> {
  bool isLoading = true;
  bool showPassword = false;

  final service = CredentialService(ApiClient());

  Map<String, dynamic>? data;

  @override
  void initState() {
    super.initState();
    _loadCredential();
  }

  Future<void> _loadCredential() async {
    try {
      setState(() => isLoading = true);
      final result = await service.getCredentialById(widget.id);
      if (!mounted) return;
      setState(() {
        data = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  void _copy(String value, String label) {
    Clipboard.setData(ClipboardData(text: value));
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
                // Appbar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
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
                      Expanded(
                        child: Text(
                          data == null ? "" : (data!["title"] ?? "Credential"),
                          style: GoogleFonts.outfit(
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(22, 4, 22, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionLabel("Account"),
                        const SizedBox(height: 8),
                        _buildField(
                          context,
                          icon: HugeIcons.strokeRoundedAt,
                          label: "Email / Username",
                          value: data == null
                              ? ""
                              : (data!["email_or_username"] ?? ""),
                          copyable: true,
                        ),

                        const SizedBox(height: 10),

                        // Password field
                        _buildPasswordField(context),

                        const SizedBox(height: 24),

                        if (data != null &&
                            (data!["login_url"] ?? "")
                                .toString()
                                .isNotEmpty) ...[
                          _sectionLabel("Login URL"),
                          const SizedBox(height: 8),
                          _buildField(
                            context,
                            icon: HugeIcons.strokeRoundedLink01,
                            label: "URL",
                            value: data == null
                                ? ""
                                : (data!["login_url"] ?? ""),
                            copyable: true,
                          ),
                          const SizedBox(height: 24),
                        ],

                        if (data != null &&
                            (data!["description"] ?? "")
                                .toString()
                                .isNotEmpty) ...[
                          _sectionLabel("Notes"),
                          const SizedBox(height: 8),
                          _buildField(
                            context,
                            icon: HugeIcons.strokeRoundedNote01,
                            label: "Description",
                            value: data == null
                                ? ""
                                : (data!["description"] ?? ""),
                          ),
                        ],

                        SizedBox(height: 28),
                        HoldToDeleteButton(
                          text: "Delete Credential",
                          icon: HugeIcons.strokeRoundedDelete01,
                          onDelete: () async {
                            await service.deleteCredential(data!["id"]);
                          },
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
            child: AppLoader(message: "Loading credential..."),
          ),
      ],
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: Theme.of(context).colorScheme.onSurface.withAlpha(120),
      ),
    );
  }

  Widget _buildField(
    BuildContext context, {
    required dynamic icon,
    required String label,
    required String value,
    bool copyable = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.onSurface.withAlpha(20),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          HugeIcon(icon: icon, color: colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: colorScheme.onSurface.withAlpha(120),
                  ),
                ),
                const SizedBox(height: 3),
                Padding(
                  padding: const EdgeInsets.only(left: 2, right: 18),
                  child: Text(
                    value,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (copyable)
            GestureDetector(
              onTap: () => _copy(value, label),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedCopy01,
                color: colorScheme.onSurface.withAlpha(120),
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final password = data == null ? "" : (data!["password"] ?? "");

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.onSurface.withAlpha(20),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          HugeIcon(
            icon: HugeIcons.strokeRoundedLockPassword,
            color: colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Password",
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: colorScheme.onSurface.withAlpha(120),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  showPassword ? password : "••••••••••",
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                    letterSpacing: showPassword ? 0 : 2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => setState(() => showPassword = !showPassword),
            child: HugeIcon(
              icon: showPassword
                  ? HugeIcons.strokeRoundedViewOff
                  : HugeIcons.strokeRoundedView,
              color: colorScheme.onSurface.withAlpha(120),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _copy(password, "Password"),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedCopy01,
              color: colorScheme.onSurface.withAlpha(120),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
