import 'package:flutter/material.dart';

class AppColors {
  // =========================
  // Brand Colors
  // =========================
  static const Color primary = Color(0xFF7C3AED);
  static const Color secondary = Color(0xFF1C1C28);

  // =========================
  // Light Theme
  // =========================
  static const Color lightPrimary = primary;
  static const Color lightSecondary = secondary;

  static const Color lightText = Color(0xFF111827);
  static const Color lightHintText = Color(0xFF6B7280);
  static const Color lightBorder = Color(0xFFE5E7EB);

  // =========================
  // Dark Theme
  // =========================
  static const Color darkPrimary = primary;
  static const Color darkSecondary = secondary;

  // Main dark background
  static const Color darkBackground = Color.fromARGB(255, 0, 0, 0);
  static const Color lightBackground = Color.fromARGB(255, 255, 255, 255);
  // Card / surface colors

  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color darkSurface = Color(0xFF18181F);
  static const Color darkCard = Color(0xFF1F1F28);

  static const Color darkText = Color(0xFFFFFFFF);
  static const Color darkHintText = Color(0xFF9CA3AF);
  static const Color darkBorder = Color(0xFF2C2C36);

  // =========================
  // Category Colors
  // =========================

  // Music
  static const Color music = Color(0xFF7C3AED);

  // Tech
  static const Color tech = Color(0xFF22C55E);

  // Gaming
  static const Color gaming = Color(0xFFEC4899);

  // Food
  static const Color food = Color(0xFFF59E0B);

  // Sports
  static const Color sports = Color(0xFF3B82F6);

  // Meetup
  static const Color meetup = Color(0xFF14B8A6);

  // =========================
  // Common Colors
  // =========================
  static const Color whiteText = Colors.white;
  static const Color blackText = Colors.black;

  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  static const Color darkLoadingColor = Colors.white;
  static const Color lightLoadingColor = Colors.black;

  // =========================
  // Map Pin Colors
  // =========================
  static const Color mapPin = primary;
  static const Color mapPinGlow = Color(0x667C3AED);

  // =========================
  // Gradients
  // =========================
  static LinearGradient primaryGradient(Color accentColor) {
    return LinearGradient(
      colors: [
        Color.lerp(Colors.black, accentColor, 0.35)!,
        accentColor.withValues(alpha: 0.65),
        Color.lerp(accentColor, Colors.white, 0.28)!,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  //====MARKER COLORS ===
  static final List<Color> markerColors = [
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.teal,
    Colors.amber,
    Colors.indigo,
  ];
}
