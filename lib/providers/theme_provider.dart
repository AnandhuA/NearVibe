import 'package:flutter/material.dart';
import 'package:near_vibe/core/themes/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _accentColorKey = 'accent_color';

  static const List<Color> accentColors = [
    AppColors.primary,
    Color(0xFF9333EA),
    Color(0xFF4F46E5),
    Color(0xFF2563EB),
    Color(0xFF0284C7),
    Color(0xFF0891B2),
    Color(0xFF0D9488),
    Color(0xFF16A34A),
    Color(0xFF65A30D),
    Color(0xFFCA8A04),
    Color(0xFFEA580C),
    Color(0xFFDC2626),
    Color(0xFFE11D48),
    Color(0xFFDB2777),
    Color(0xFF7F1D1D),
    Color(0xFF334155),
    Color(0xFF111827),
  ];

  ThemeMode _themeMode = ThemeMode.system;
  Color _accentColor = AppColors.primary;

  ThemeMode get themeMode => _themeMode;
  Color get accentColor => _accentColor;

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);
    final savedAccentColor = prefs.getInt(_accentColorKey);

    _themeMode = switch (savedTheme) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    if (savedAccentColor != null) {
      _accentColor = Color(savedAccentColor);
    }

    notifyListeners();
  }

  Future<void> setTheme(ThemeMode mode) async {
    _themeMode = mode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.name);

    notifyListeners();
  }

  Future<void> setAccentColor(Color color) async {
    _accentColor = color;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_accentColorKey, color.toARGB32());

    notifyListeners();
  }
}
