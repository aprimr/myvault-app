import 'package:app/core/color_pallete.dart';
import 'package:app/core/service_locator.dart';
import 'package:app/services/notes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:app/widgets/app_loader.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  bool isLoading = true;
  List<dynamic> notes = [];
  List<dynamic> filtered = [];
  final _searchController = TextEditingController();

  late NoteService service;

  @override
  void initState() {
    super.initState();
    service = NoteService(apiClient);
    _searchController.addListener(_onSearch);
    _init();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      filtered = notes.where((item) {
        return (item["title"] ?? "").toLowerCase().contains(q) ||
            (item["content"] ?? "").toLowerCase().contains(q);
      }).toList();
    });
  }

  Future<void> _init() async {
    await _loadNotes();
  }

  Future<void> _loadNotes() async {
    try {
      setState(() => isLoading = true);
      final rawData = await service.getAllNotes();
      final data = rawData.reversed.toList();
      if (!mounted) return;
      setState(() {
        notes = data;
        filtered = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
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
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 16,
                  ),

                  // AppBar
                  child: Row(
                    children: [
                      Text(
                        "Notes",
                        style: GoogleFonts.outfit(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Search bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
                  child: TextField(
                    controller: _searchController,
                    style: GoogleFonts.outfit(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: "Search notes...",
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 14,
                        color: colorScheme.onSurface.withAlpha(100),
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(13),
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedSearch01,
                          color: colorScheme.onSurface.withAlpha(120),
                        ),
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 12,
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest,
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
                ),

                Expanded(
                  child: isLoading
                      ? const SizedBox()
                      : RefreshIndicator(
                          onRefresh: _loadNotes,
                          child: filtered.isEmpty
                              ? ListView(
                                  children: [
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                          0.6,
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 32,
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                "No Notes Yet",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.w600,
                                                  color: colorScheme.onSurface,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                "Keep your notes safe and access them whenever you want.",
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.outfit(
                                                  fontSize: 18,
                                                  color: colorScheme.onSurface
                                                      .withAlpha(150),
                                                ),
                                              ),
                                              const SizedBox(height: 38),
                                              FilledButton.icon(
                                                onPressed: () {},
                                                icon: const Icon(
                                                  Icons.add,
                                                  size: 24,
                                                ),
                                                label: Text(
                                                  "Add a Note",
                                                  style: GoogleFonts.outfit(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                style: FilledButton.styleFrom(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 24,
                                                        vertical: 12,
                                                      ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : MasonryGridView.count(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 22,
                                    vertical: 4,
                                  ),
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                  itemCount: filtered.length,
                                  itemBuilder: (context, index) {
                                    final item = filtered[index];
                                    final color = ColorPallete.random();

                                    return GestureDetector(
                                      onTap: () {},
                                      child: Card(
                                        color: color.withAlpha(24),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              HugeIcon(
                                                icon:
                                                    HugeIcons.strokeRoundedNote,
                                                color: color,
                                                size: 26,
                                              ),
                                              const SizedBox(height: 12),
                                              Text(
                                                item["title"] ?? "",
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w500,
                                                  color: colorScheme.onSurface,
                                                ),
                                              ),
                                              if ((item["content"] ?? "")
                                                  .isNotEmpty) ...[
                                                const SizedBox(height: 6),
                                                Text(
                                                  item["content"] ?? "",
                                                  maxLines: 5,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 12,
                                                    color: colorScheme.onSurface
                                                        .withAlpha(200),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                ),
              ],
            ),
          ),

          floatingActionButton: notes.isEmpty
              ? null
              : FloatingActionButton.extended(
                  onPressed: () {},
                  elevation: 0,
                  hoverElevation: 0,
                  backgroundColor: colorScheme.primary,
                  label: Row(
                    children: [
                      const HugeIcon(
                        icon: HugeIcons.strokeRoundedAdd01,
                        size: 22,
                        strokeWidth: 2,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Add a Note",
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
        ),

        if (isLoading)
          const Positioned.fill(child: AppLoader(message: "Fetching notes...")),
      ],
    );
  }
}
