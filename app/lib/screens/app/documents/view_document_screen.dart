import 'package:app/core/service_locator.dart';
import 'package:app/services/document.dart';
import 'package:app/utils/date_formatter.dart';
import 'package:app/widgets/app_loader.dart';
import 'package:app/widgets/hold_to_delete_button.dart';
import 'package:app/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

class ViewDocumentScreen extends StatefulWidget {
  final String documentId;

  const ViewDocumentScreen({super.key, required this.documentId});

  @override
  State<ViewDocumentScreen> createState() => _ViewDocumentScreenState();
}

class _ViewDocumentScreenState extends State<ViewDocumentScreen> {
  bool isLoading = true;
  bool isDeleting = false;
  Map<String, dynamic>? document;

  late final DocumentService documentService;

  @override
  void initState() {
    super.initState();
    documentService = DocumentService(apiClient);
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    try {
      setState(() => isLoading = true);
      final data = await documentService.getDocumentById(widget.documentId);
      if (!mounted) return;
      setState(() {
        document = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      AppSnackbar.show(
        context,
        message: "Failed to load document",
        isError: true,
      );
    }
  }

  Future<void> _delete() async {
    setState(() => isDeleting = true);

    try {
      await documentService.deleteDocument(widget.documentId);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => isDeleting = false);
      AppSnackbar.show(
        context,
        message: "Failed to delete document",
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fileUrl = document?["document_url"] ?? "";
    final title = document?["title"] ?? "";
    final description = document?["description"] ?? "";
    final createdAt = DateFormatter.toSimpleDate(document?["CreatedAt"] ?? "");

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
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 26,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: isLoading
                      ? const SizedBox()
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(22, 0, 22, 40),
                          children: [
                            // Description
                            if (description != "") ...[
                              const SizedBox(height: 8),
                              Text(
                                description,
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  height: 1.6,
                                  color: colorScheme.onSurface.withAlpha(200),
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],

                            // Image preview
                            if (fileUrl.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  fileUrl,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return Container(
                                          height: 240,
                                          decoration: BoxDecoration(
                                            color: colorScheme
                                                .surfaceContainerHighest,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              value:
                                                  loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                  : null,
                                              color: colorScheme.primary,
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        );
                                      },
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        height: 240,
                                        decoration: BoxDecoration(
                                          color: colorScheme
                                              .surfaceContainerHighest,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              HugeIcon(
                                                icon: HugeIcons
                                                    .strokeRoundedImageNotFound01,
                                                color: colorScheme.onSurface
                                                    .withAlpha(80),
                                                size: 36,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                "Failed to load image",
                                                style: GoogleFonts.outfit(
                                                  fontSize: 14,
                                                  color: colorScheme.onSurface
                                                      .withAlpha(100),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                ),
                              ),

                            const SizedBox(height: 14),

                            Row(
                              children: [
                                Text(
                                  "Added on",
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: colorScheme.onSurface.withAlpha(120),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  createdAt,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: colorScheme.onSurface.withAlpha(120),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Delete button
                            HoldToDeleteButton(
                              text: "Delete Document",
                              onDelete: _delete,
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),

        if (isLoading || isDeleting)
          Positioned.fill(
            child: AppLoader(
              message: isDeleting ? "Deleting document..." : "Loading...",
            ),
          ),
      ],
    );
  }
}
