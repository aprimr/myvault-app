import 'package:app/core/color_pallete.dart';
import 'package:app/core/routes.dart';
import 'package:app/core/service_locator.dart';
import 'package:app/services/document.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:app/widgets/app_loader.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  bool isLoading = true;
  List<dynamic> documents = [];
  List<dynamic> filtered = [];
  final _searchController = TextEditingController();

  late DocumentService service;

  @override
  void initState() {
    super.initState();
    service = DocumentService(apiClient);
    _searchController.addListener(_onSearch);
    _loadDocuments();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      filtered = documents.where((item) {
        return (item["title"] ?? "").toLowerCase().contains(q) ||
            (item["description"] ?? "").toLowerCase().contains(q);
      }).toList();
    });
  }

  Future<void> _loadDocuments() async {
    try {
      setState(() => isLoading = true);
      final rawData = await service.getAllDocuments();
      final data = rawData.reversed.toList();
      if (!mounted) return;
      setState(() {
        documents = data;
        filtered = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  List<List<dynamic>> _fileIcon(String? title) {
    final ext = (title ?? "").split(".").last.toLowerCase();
    switch (ext) {
      case "pdf":
        return HugeIcons.strokeRoundedPdf01;
      case "jpg":
      case "jpeg":
      case "png":
      case "webp":
        return HugeIcons.strokeRoundedImage01;
      case "doc":
      case "docx":
        return HugeIcons.strokeRoundedDoc01;
      case "xls":
      case "xlsx":
        return HugeIcons.strokeRoundedXls01;
      default:
        return HugeIcons.strokeRoundedFile01;
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
                // AppBar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      Text(
                        "Documents",
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
                      hintText: "Search documents...",
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
                          onRefresh: _loadDocuments,
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
                                                "No Documents Yet",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.w600,
                                                  color: colorScheme.onSurface,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                "Store your important files securely\nand access them anytime.",
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.outfit(
                                                  fontSize: 18,
                                                  color: colorScheme.onSurface
                                                      .withAlpha(150),
                                                ),
                                              ),
                                              const SizedBox(height: 38),
                                              FilledButton.icon(
                                                onPressed: () async {
                                                  final added =
                                                      await Navigator.pushNamed(
                                                        context,
                                                        AppRoutes
                                                            .addDocumentRoute,
                                                      );
                                                  if (added == true) {
                                                    _loadDocuments();
                                                  }
                                                },
                                                icon: const Icon(
                                                  Icons.add,
                                                  size: 24,
                                                ),
                                                label: Text(
                                                  "Add Document",
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
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 22,
                                    vertical: 4,
                                  ),
                                  itemCount: filtered.length,
                                  itemBuilder: (context, index) {
                                    final item = filtered[index];
                                    final color = ColorPallete.random();

                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 10,
                                      ),
                                      child: GestureDetector(
                                        onTap: () async {
                                          final deleted =
                                              await Navigator.pushNamed(
                                                context,
                                                AppRoutes.viewDocumentRoute,
                                                arguments: item["id"],
                                              );
                                          if (deleted == true) {
                                            _loadDocuments();
                                          }
                                        },
                                        child: Card(
                                          color: color.withAlpha(24),
                                          elevation: 0,
                                          child: ListTile(
                                            leading: HugeIcon(
                                              icon: _fileIcon(item["title"]),
                                              color: color,
                                            ),
                                            title: Text(
                                              item["title"] ?? "",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: colorScheme.onSurface,
                                              ),
                                            ),
                                            subtitle: item["description"] == ""
                                                ? null
                                                : Text(
                                                    item["description"] ??
                                                        "No description",
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 13,
                                                      color: colorScheme
                                                          .onSurface
                                                          .withAlpha(160),
                                                    ),
                                                  ),
                                            trailing: HugeIcon(
                                              icon: HugeIcons
                                                  .strokeRoundedArrowRight01,
                                              size: 20,
                                              color: color,
                                            ),
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

          floatingActionButton: documents.isEmpty
              ? null
              : FloatingActionButton.extended(
                  onPressed: () async {
                    final added = await Navigator.pushNamed(
                      context,
                      AppRoutes.addDocumentRoute,
                    );
                    if (added == true) {
                      _loadDocuments();
                    }
                  },
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
                        "Add Document",
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
          const Positioned.fill(
            child: AppLoader(message: "Fetching documents..."),
          ),
      ],
    );
  }
}
