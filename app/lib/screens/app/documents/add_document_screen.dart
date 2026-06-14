import 'package:app/core/service_locator.dart';
import 'package:app/services/document.dart';
import 'package:app/widgets/app_loader.dart';
import 'package:app/widgets/snackbar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'dart:io';

class AddDocumentScreen extends StatefulWidget {
  const AddDocumentScreen({super.key});

  @override
  State<AddDocumentScreen> createState() => _AddDocumentScreenState();
}

class _AddDocumentScreenState extends State<AddDocumentScreen> {
  bool isLoading = false;

  late final DocumentService documentService;

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  XFile? _pickedFile;
  int? _fileSize;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    documentService = DocumentService(apiClient);
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _showPickerOptions() {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withAlpha(40),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Select Image",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            _PickerOption(
              icon: HugeIcons.strokeRoundedCamera01,
              label: "Take a Photo",
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            const SizedBox(height: 10),
            _PickerOption(
              icon: HugeIcons.strokeRoundedImage01,
              label: "Choose from Gallery",
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 90);

    if (picked == null) return;

    final bytes = await picked.length();

    setState(() {
      _pickedFile = picked;
      _fileSize = bytes;
      if (titleController.text.trim().isEmpty) {
        titleController.text = picked.name.replaceAll(RegExp(r'\.[^\.]+$'), '');
      }
    });
  }

  String _formatFileSize(int? bytes) {
    if (bytes == null) return "";
    if (bytes < 1024) return "$bytes B";
    if (bytes < 1024 * 1024) return "${(bytes / 1024).toStringAsFixed(1)} KB";
    return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
  }

  Future<void> _submit() async {
    final title = titleController.text.trim();

    if (_pickedFile == null) {
      AppSnackbar.show(
        context,
        message: "Please select an image",
        isError: true,
      );
      return;
    }

    if (title.isEmpty) {
      AppSnackbar.show(context, message: "Title is required", isError: true);
      return;
    }

    setState(() => isLoading = true);

    try {
      await documentService.addDocument(
        filePath: _pickedFile!.path,
        title: title,
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
        message: "Failed to upload document",
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
                        "Add Document",
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
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 100),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 26),
                        child: Text(
                          "Your documents are stored securely and can only be accessed by you.",
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            color: colorScheme.onSurface.withAlpha(130),
                          ),
                        ),
                      ),

                      // Image picker area
                      GestureDetector(
                        onTap: _showPickerOptions,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: _pickedFile != null
                                ? colorScheme.primary.withAlpha(16)
                                : colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _pickedFile != null
                                  ? colorScheme.primary.withAlpha(120)
                                  : colorScheme.onSurface.withAlpha(40),
                              width: 1.6,
                              strokeAlign: BorderSide.strokeAlignInside,
                            ),
                          ),
                          child: _pickedFile == null
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 28,
                                  ),
                                  child: Column(
                                    children: [
                                      HugeIcon(
                                        icon: HugeIcons.strokeRoundedUpload04,
                                        color: colorScheme.onSurface.withAlpha(
                                          120,
                                        ),
                                        size: 36,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        "Tap to select an image",
                                        style: GoogleFonts.outfit(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.onSurface
                                              .withAlpha(160),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Camera or gallery",
                                        style: GoogleFonts.outfit(
                                          fontSize: 13,
                                          color: colorScheme.onSurface
                                              .withAlpha(100),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Column(
                                  children: [
                                    // Image preview
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(14),
                                      ),
                                      child: Image.file(
                                        File(_pickedFile!.path),
                                        width: double.infinity,
                                        height: 220,
                                        fit: BoxFit.cover,
                                      ),
                                    ),

                                    // File info row
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: colorScheme.primary
                                                  .withAlpha(256),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Center(
                                              child: HugeIcon(
                                                icon: HugeIcons
                                                    .strokeRoundedImage01,
                                                color: colorScheme.primary,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _pickedFile!.name,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        colorScheme.onSurface,
                                                  ),
                                                ),
                                                Text(
                                                  _formatFileSize(_fileSize),
                                                  style: GoogleFonts.outfit(
                                                    fontSize: 12,
                                                    color: colorScheme.onSurface
                                                        .withAlpha(140),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () => setState(() {
                                              _pickedFile = null;
                                              _fileSize = null;
                                            }),
                                            child: HugeIcon(
                                              icon: HugeIcons
                                                  .strokeRoundedCancelCircle,
                                              color: colorScheme.error,
                                              size: 22,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // Title
                      _FieldLabel(label: "Title"),
                      const SizedBox(height: 8),
                      TextField(
                        controller: titleController,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: "Enter document title",
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 15,
                            color: colorScheme.onSurface.withAlpha(100),
                          ),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: colorScheme.onSurface.withAlpha(40),
                              width: 1.4,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: colorScheme.primary.withAlpha(200),
                              width: 1.4,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Description
                      _FieldLabel(label: "Description (optional)"),
                      const SizedBox(height: 8),
                      TextField(
                        controller: descriptionController,
                        maxLines: 3,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: "Enter a short description...",
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 15,
                            color: colorScheme.onSurface.withAlpha(100),
                          ),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: colorScheme.onSurface.withAlpha(40),
                              width: 1.4,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: colorScheme.primary.withAlpha(200),
                              width: 1.4,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Submit
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _submit,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            "Upload Document",
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
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

        if (isLoading)
          const Positioned.fill(
            child: AppLoader(message: "Uploading document..."),
          ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.outfit(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
        letterSpacing: 0.4,
      ),
    );
  }
}

class _PickerOption extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String label;
  final VoidCallback onTap;

  const _PickerOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            HugeIcon(icon: icon, color: colorScheme.primary, size: 20),
            const SizedBox(width: 14),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
