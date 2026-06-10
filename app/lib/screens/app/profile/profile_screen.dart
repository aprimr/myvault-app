import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/widgets/app_loader.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 14,
                  ),
                  // App Bar
                  child: Row(
                    children: [
                      Text(
                        "Profile",
                        style: GoogleFonts.outfit(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: cs.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Body
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text("profile here"),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Loader overlay
          if (isLoading) const AppLoader(message: "Fetching data..."),
        ],
      ),
    );
  }
}
