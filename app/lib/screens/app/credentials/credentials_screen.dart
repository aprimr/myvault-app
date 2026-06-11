import 'package:app/core/color_pallete.dart';
import 'package:app/core/routes.dart';
import 'package:app/services/credential.dart';
import 'package:app/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

import 'package:app/widgets/app_loader.dart';
import 'package:app/core/storage.dart';
import 'package:app/core/api.dart';

class CredentialsScreen extends StatefulWidget {
  const CredentialsScreen({super.key});

  @override
  State<CredentialsScreen> createState() => _CredentialsScreenState();
}

class _CredentialsScreenState extends State<CredentialsScreen> {
  bool isLoading = true;
  List<dynamic> credentials = [];
  List<dynamic> filtered = [];
  final _searchController = TextEditingController();

  late final CredentialService service;
  final storage = SecureStorage();

  @override
  void initState() {
    super.initState();
    service = CredentialService(ApiClient());
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
      filtered = credentials.where((item) {
        return (item["title"] ?? "").toLowerCase().contains(q) ||
            (item["email_or_username"] ?? "").toLowerCase().contains(q);
      }).toList();
    });
  }

  Future<void> _init() async {
    final token = await storage.getToken();
    if (token == null) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.loginRoute);
      AppSnackbar.show(context, message: "Please relogin", isError: true);
      return;
    }
    await _loadCredentials();
  }

  Future<void> _loadCredentials() async {
    try {
      setState(() => isLoading = true);
      final data = await service.getAllCredentials();
      if (!mounted) return;
      setState(() {
        credentials = data;
        filtered = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      debugPrint("Error loading credentials: $e");
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
                        "Credentials",
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
                      hintText: "Search credentials...",
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
                          onRefresh: _loadCredentials,
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
                                                "No Credentials Yet",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.w600,
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.onSurface,
                                                ),
                                              ),

                                              const SizedBox(height: 8),

                                              Text(
                                                "Store your login details securely\nand access them anytime.",
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.outfit(
                                                  fontSize: 18,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface
                                                      .withAlpha(150),
                                                ),
                                              ),

                                              const SizedBox(height: 38),

                                              FilledButton.icon(
                                                onPressed: () {
                                                  Navigator.pushNamed(
                                                    context,
                                                    AppRoutes
                                                        .addCredentialRoute,
                                                  );
                                                },
                                                icon: const Icon(
                                                  Icons.add,
                                                  size: 24,
                                                ),
                                                label: Text(
                                                  "Add Credential",
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
                                        onTap: () {
                                          Navigator.pushNamed(
                                            context,
                                            AppRoutes.viewCredentialRoute,
                                            arguments: item["id"],
                                          );
                                        },
                                        child: Card(
                                          color: color.withAlpha(24),
                                          elevation: 0,
                                          child: ListTile(
                                            leading: HugeIcon(
                                              icon: HugeIcons
                                                  .strokeRoundedLockPassword,
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
                                            subtitle: Text(
                                              item["email_or_username"] ?? "",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                color: colorScheme.onSurface
                                                    .withAlpha(200),
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

          floatingActionButton: credentials.isEmpty
              ? null
              : FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.addCredentialRoute);
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
                        "Add Credential",
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
            child: AppLoader(message: "Fetching credentials..."),
          ),
      ],
    );
  }
}
