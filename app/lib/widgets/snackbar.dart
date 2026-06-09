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

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(
            color: isError ? colorScheme.onErrorContainer : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),

        backgroundColor: isError
            ? colorScheme.errorContainer
            : colorScheme.primary,

        behavior: SnackBarBehavior.floating,

        elevation: 0,
        margin: const EdgeInsets.only(left: 22, right: 22, bottom: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),

        duration: const Duration(seconds: 3),
        action: actionLabel != null && onAction != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: colorScheme.primary,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }
}
