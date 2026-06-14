import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  static const supportEmail = "bambotech.mail@gmail.com";

  void _handleCopyEmail(BuildContext context) {
    Clipboard.setData(ClipboardData(text: supportEmail));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AppBar Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                    "About & Support",
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                children: [
                  const SizedBox(height: 28),

                  // About
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedSafeBox,
                        color: colorScheme.primary,
                        size: 36,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'About',
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
                      const SizedBox(height: 10),
                      Text(
                        "My Vault is a secure platform built to store and protect your credentials, private notes, and documents. All your sensitive information is processed using industry-standard protection layers before it ever reaches our permanent databases.",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          height: 1.5,
                          color: colorScheme.onSurface.withAlpha(140),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Support Section
                  _buildSectionLabel(context, "Support"),
                  const SizedBox(height: 8),
                  _buildTileCard(context, [
                    ListTile(
                      leading: HugeIcon(
                        icon: HugeIcons.strokeRoundedMail01,
                        color: colorScheme.onSurface.withAlpha(180),
                        size: 20,
                      ),
                      title: Text(
                        supportEmail,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        "Get help within 72 hours",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: colorScheme.onSurface.withAlpha(120),
                        ),
                      ),
                      trailing: HugeIcon(
                        icon: HugeIcons.strokeRoundedCopy,
                        color: colorScheme.primary,
                        size: 18,
                      ),
                      onTap: () => _handleCopyEmail(context),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Legal Section
                  _buildSectionLabel(context, "Legal & Privacy"),
                  const SizedBox(height: 8),
                  _buildTileCard(context, [
                    _buildNavigationTile(
                      context,
                      icon: HugeIcons.strokeRoundedShield01,
                      title: "Privacy Policy",
                      onTap: () => _showTextModal(
                        context,
                        title: "Privacy Policy",
                        content:
                            "• Data Encryption: All stored credentials and notes are encrypted server-side using AES-256-GCM before writing to our PostgreSQL database.\n\n• Document Storage: Uploaded files are hosted securely via Cloudinary. Paths and access URLs pointing to these resources remain encrypted inside our system storage tables.\n\n• Account Deletion: You retain absolute control over your records. Contact our support desk to request account removal, and your entire database records alongside your hosted files will be safely erased within 72 hours.",
                      ),
                    ),
                    _buildNavigationTile(
                      context,
                      icon: HugeIcons.strokeRoundedFile02,
                      title: "Terms of Service",
                      onTap: () => _showTextModal(
                        context,
                        title: "Terms of Service",
                        content:
                            "• Platform Use: My Vault delivers tools designed to manage personal database details, records, and files. Account managers retain full accountability over their login parameters.\n\n• Service Disclaimer: This application functions as an independent project and does not feature active company registration. While we build upon reliable industry-accepted backend protection architectures, the services are delivered as-is.",
                      ),
                    ),
                    _buildNavigationTile(
                      context,
                      icon: HugeIcons.strokeRoundedLicense,
                      title: "Open Source Licenses",
                      onTap: () => showLicensePage(context: context),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // FAQ Section
                  _buildSectionLabel(context, "Frequently Asked Questions"),
                  const SizedBox(height: 8),
                  _buildFaqItem(
                    context,
                    question: "How is my data protected?",
                    answer:
                        "Your credentials and notes are securely encrypted server-side using AES-256-GCM before being written to the database. All incoming and outgoing connections travel over secure HTTPS links.",
                  ),
                  _buildFaqItem(
                    context,
                    question: "Where are documents stored?",
                    answer:
                        "Files are uploaded cleanly to Cloudinary, while their exact web access routes/URLs are encrypted inside our central PostgreSQL tracking tables.",
                  ),
                  _buildFaqItem(
                    context,
                    question:
                        "How do I verify my email if I missed it during registration?",
                    answer:
                        "Simply navigate to the login screen, click on the 'Forgot Password'.Enter your email address and click 'Continue' and verify the OTP sent to your email.  Once you verify the OTP, choose a new password (or enter your original password again) to mark your email profile successfully verified.",
                  ),
                  _buildFaqItem(
                    context,
                    question: "How do I wipe my data permanently?",
                    answer:
                        "Email your deletion request to support@myvault.com. We will systematically remove all account rows, notes, keys, and Cloudinary media assets within 72 hours.",
                  ),

                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      "Version 1.0.0",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: colorScheme.onSurface.withAlpha(120),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildTileCard(BuildContext context, List<Widget> children) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withAlpha(8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.onSurface.withAlpha(12)),
      ),
      child: Column(
        children: Iterable<int>.generate(children.length).map((index) {
          return Column(
            children: [
              children[index],
              if (index < children.length - 1)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: colorScheme.onSurface.withAlpha(10),
                  indent: 52,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNavigationTile(
    BuildContext context, {
    required List<List<dynamic>> icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: HugeIcon(
        icon: icon,
        color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
        size: 20,
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      trailing: HugeIcon(
        icon: HugeIcons.strokeRoundedArrowRight01,
        color: Theme.of(context).colorScheme.onSurface.withAlpha(80),
        size: 16,
      ),
      onTap: onTap,
    );
  }

  Widget _buildFaqItem(
    BuildContext context, {
    required String question,
    required String answer,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: colorScheme.onSurface.withAlpha(8),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colorScheme.onSurface.withAlpha(12)),
        ),
        child: ExpansionTile(
          iconColor: colorScheme.primary,
          collapsedIconColor: colorScheme.onSurface.withAlpha(120),
          title: Text(
            question,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Text(
                answer,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  height: 1.5,
                  color: colorScheme.onSurface.withAlpha(140),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTextModal(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        maxChildSize: 0.85,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              content,
              style: GoogleFonts.poppins(
                fontSize: 13,
                height: 1.6,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
