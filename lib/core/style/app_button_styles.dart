import 'package:flutter/material.dart';

class AppButtonStyles {
  static ButtonStyle elevatedButton(Color accentColor) {
    return ElevatedButton.styleFrom(
      backgroundColor: accentColor,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(vertical: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  }

  static ButtonStyle textButton(Color accentColor) {
    return TextButton.styleFrom(
      foregroundColor: accentColor,
      padding: const EdgeInsets.symmetric(vertical: 18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: accentColor, width: 1.5),
      ),
    );
  }
}
