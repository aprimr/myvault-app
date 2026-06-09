import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    bool isError = false,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),

        backgroundColor: isError ? Colors.redAccent : colorScheme.primary,

        behavior: SnackBarBehavior.floating,

        elevation: 0,
        margin: const EdgeInsets.all(22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),

        duration: const Duration(seconds: 3),
        action: actionLabel != null && onAction != null
            ? SnackBarAction(
                backgroundColor: Colors.white,
                label: actionLabel,
                textColor: Colors.black,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }
}
