import 'package:flutter/material.dart';
import 'package:near_vibe/core/style/app_button_styles.dart';
import 'package:near_vibe/core/themes/app_colors.dart';
import 'package:near_vibe/core/style/app_input_styles.dart';

class AppTheme {
  //-------------------Light Theme--------------------------
  static ThemeData lightTheme(Color accentColor) {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: accentColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentColor,
        brightness: Brightness.light,
      ).copyWith(
        primary: accentColor,
        secondary: accentColor,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: AppButtonStyles.elevatedButton(accentColor),
      ),
      textButtonTheme: TextButtonThemeData(
        style: AppButtonStyles.textButton(accentColor),
      ),
      inputDecorationTheme: AppInputStyles.lightInputDecorationTheme(
        accentColor,
      ),
    );
  }

  //-------------------Dark Theme--------------------------
  static ThemeData darkTheme(Color accentColor) {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: accentColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentColor,
        brightness: Brightness.dark,
      ).copyWith(
        primary: accentColor,
        secondary: accentColor,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: AppButtonStyles.elevatedButton(accentColor),
      ),
      textButtonTheme: TextButtonThemeData(
        style: AppButtonStyles.textButton(accentColor),
      ),

      inputDecorationTheme: AppInputStyles.darkInputDecorationTheme(
        accentColor,
      ),
    );
  }
}
