import 'package:app/core/service_locator.dart';
import 'package:app/services/notes.dart';
import 'package:app/utils/date_formatter.dart';
import 'package:app/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:app/widgets/app_loader.dart';

class ViewNoteScreen extends StatefulWidget {
  final String noteId;

  const ViewNoteScreen({super.key, required this.noteId});

  @override
  State<ViewNoteScreen> createState() => _ViewNoteScreenState();
}

class _ViewNoteScreenState extends State<ViewNoteScreen> {
  bool isLoading = true;
  bool isEditing = false;
  bool isSaving = false;
  bool isDeleting = false;

  late final NoteService noteService;

  final titleController = TextEditingController();
  final contentController = TextEditingController();

  late String updatedAt = "";

  final FocusNode _titleFocus = FocusNode();
  final FocusNode _contentFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    noteService = NoteService(apiClient);
    _loadNote();
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    _titleFocus.dispose();
    _contentFocus.dispose();
    super.dispose();
  }

  Future<void> _loadNote() async {
    try {
      setState(() => isLoading = true);
      final data = await noteService.getNoteById(widget.noteId);
      if (!mounted) return;
      titleController.text = data["title"] ?? "";
      contentController.text = data["content"] ?? "";

      updatedAt = data["updated_at"] ?? "";

      setState(() => isLoading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      AppSnackbar.show(context, message: "Failed to load note", isError: true);
    }
  }

  Future<void> _update() async {
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

    setState(() => isSaving = true);

    try {
      await noteService.updateNote(
        id: widget.noteId,
        title: title,
        content: content,
      );

      if (!mounted) return;
      setState(() {
        isSaving = false;
        isEditing = false;
      });

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => isSaving = false);
      AppSnackbar.show(
        context,
        message: "Failed to update note",
        isError: true,
      );
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          "Delete Note?",
          style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w600),
        ),
        content: Text(
          "Are you sure you want to delete this note? This action cannot be undone.",
          style: GoogleFonts.poppins(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text("Cancel", style: GoogleFonts.outfit(fontSize: 16)),
          ),
          SizedBox(width: 8),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              "Delete",
              style: GoogleFonts.outfit(color: Colors.red, fontSize: 16),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => isDeleting = true);

    try {
      await noteService.deleteNote(widget.noteId);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => isDeleting = false);
      AppSnackbar.show(
        context,
        message: "Failed to delete note",
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
                      const Spacer(),

                      if (!isLoading) ...[
                        if (!isEditing)
                          GestureDetector(
                            onTap: () {
                              setState(() => isEditing = true);
                              FocusScope.of(context).requestFocus(_titleFocus);
                            },
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedPencilEdit01,
                              color: colorScheme.primary,
                              size: 24,
                            ),
                          ),

                        const SizedBox(width: 24),

                        // Delete
                        GestureDetector(
                          onTap: _delete,
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedDelete01,
                            color: Colors.red,
                            size: 24,
                          ),
                        ),

                        const SizedBox(width: 10),
                      ],
                    ],
                  ),
                ),

                !isEditing
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(22, 10, 22, 0),
                        child: Row(
                          children: [
                            Text(
                              "Last updated: ${DateFormatter.toDateTime(updatedAt)}",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: colorScheme.onSurface.withAlpha(125),
                              ),
                            ),
                          ],
                        ),
                      )
                    : SizedBox.shrink(),

                // Title field
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 22, 0),
                  child: TextField(
                    controller: titleController,
                    focusNode: _titleFocus,
                    readOnly: !isEditing,
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
                const SizedBox(height: 14),

                // Content field
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
                    child: TextField(
                      controller: contentController,
                      focusNode: _contentFocus,
                      readOnly: !isEditing,
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

          // Show in edit mode
          floatingActionButton: isEditing
              ? FloatingActionButton.extended(
                  onPressed: _update,
                  elevation: 0,
                  hoverElevation: 0,
                  backgroundColor: colorScheme.primary,
                  label: Text(
                    "Update Note",
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : null,
        ),

        if (isLoading || isSaving || isDeleting)
          Positioned.fill(
            child: AppLoader(
              message: isDeleting
                  ? "Deleting note..."
                  : isSaving
                  ? "Updating note..."
                  : "Loading note...",
            ),
          ),
      ],
    );
  }
}
