import 'package:flutter/material.dart';
import 'package:near_vibe/core/themes/theme_extensions.dart';

class AppSnackBar {
  AppSnackBar._(); // private constructor

  static void show(
    BuildContext context, {
    required String message,
    Color backgroundColor = Colors.black87,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    final snackBar = SnackBar(
      duration: duration,
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: Row(
        children: [
          if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
          Expanded(
            child: Text(message, style: TextStyle(color: context.whiteText)),
          ),
        ],
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  /// Success snackbar
  static void success(BuildContext context, String message) {
    show(
      context,
      message: message,
      backgroundColor: context.success,
      icon: Icons.check_circle,
    );
  }

  /// Error snackbar
  static void error(BuildContext context, String message) {
    show(
      context,
      message: message,
      backgroundColor: context.error,
      icon: Icons.error,
    );
  }

  /// Error snackbar
  static void warning(BuildContext context, String message) {
    show(
      context,
      message: message,
      backgroundColor: context.warning,
      icon: Icons.warning_amber_outlined,
    );
  }
}
