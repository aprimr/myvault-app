import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppLoader extends StatelessWidget {
  final String message;

  const AppLoader({super.key, this.message = "Loading..."});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Positioned.fill(
          child: Container(color: colorScheme.secondary.withAlpha(120)),
        ),

        // Loader
        Center(
          child: Container(
            height: 65,
            width: 280,
            padding: const EdgeInsets.symmetric(horizontal: 26),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: colorScheme.primary,
                  ),
                ),

                const SizedBox(width: 22),

                Text(
                  message,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    decoration: TextDecoration.none,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
