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

  static const Color lightBackground = Color(0xFFF8F8FC);
  static const Color lightSurface = Color(0xFFFFFFFF);

  static const Color lightText = Color(0xFF111827);
  static const Color lightHintText = Color(0xFF6B7280);
  static const Color lightBorder = Color(0xFFE5E7EB);

  // =========================
  // Dark Theme
  // =========================
  static const Color darkPrimary = primary;
  static const Color darkSecondary = secondary;

  // Main dark background
  static const Color darkBackground = Color(0xFF0F0F14);

  // Card / surface colors
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

  static const Color loadingColor = Colors.white;

  // =========================
  // Map Pin Colors
  // =========================
  static const Color mapPin = primary;
  static const Color mapPinGlow = Color(0x667C3AED);

  // =========================
  // Gradients
  // =========================
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color.fromARGB(255, 18, 5, 41),
      Color(0x667C3AED),
      Color(0xFF9F67FF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
