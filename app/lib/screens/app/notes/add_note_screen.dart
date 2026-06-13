import 'package:app/core/service_locator.dart';
import 'package:app/services/notes.dart';
import 'package:app/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:app/widgets/app_loader.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  bool isLoading = false;

  late final NoteService noteService;

  final titleController = TextEditingController();
  final contentController = TextEditingController();

  final FocusNode _titleFocus = FocusNode();
  final FocusNode _contentFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    noteService = NoteService(apiClient);
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    _titleFocus.dispose();
    _contentFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = titleController.text.trim();
    final content = contentController.text;

    if (title.isEmpty) {
      AppSnackbar.show(context, message: "Title is required", isError: true);
      return;
    }

    if (content.trim().isEmpty) {
      AppSnackbar.show(context, message: "Content is required", isError: true);
      return;
    }

    setState(() => isLoading = true);

    try {
      await noteService.addNote(title: title, content: content);

      if (!mounted) return;
      setState(() => isLoading = false);
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      AppSnackbar.show(context, message: "Failed to save note", isError: true);
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
                        "Add a Note",
                        style: GoogleFonts.outfit(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),

                // Title field
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
                  child: TextField(
                    controller: titleController,
                    focusNode: _titleFocus,
                    minLines: 1,
                    maxLines: 3,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(_contentFocus),
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: "Title",
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface.withAlpha(80),
                      ),
                      fillColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),

                SizedBox(height: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
                    child: TextField(
                      controller: contentController,
                      focusNode: _contentFocus,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      keyboardType: TextInputType.multiline,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        height: 1.6,
                        color: colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: "Start writing...",
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 16,
                          color: colorScheme.onSurface.withAlpha(80),
                        ),
                        fillColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              _submit();
            },
            elevation: 0,
            hoverElevation: 0,
            backgroundColor: colorScheme.primary,
            label: Text(
              "Save Note",
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        if (isLoading)
          const Positioned.fill(child: AppLoader(message: "Saving note...")),
      ],
    );
  }
}
