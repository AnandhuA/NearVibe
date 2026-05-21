import 'package:flutter/material.dart';
import 'package:near_vibe/core/themes/app_button_styles.dart';
import 'package:near_vibe/core/themes/app_colors.dart';

class AppTheme {
  //-------------------Light Theme--------------------------
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.lightPrimary,
    scaffoldBackgroundColor: AppColors.lightBackground,

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: AppButtonStyles.elevatedButton,
    ),
    textButtonTheme: TextButtonThemeData(style: AppButtonStyles.textButton),

   
  );

  //-------------------Dark Theme--------------------------
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.darkPrimary,
    scaffoldBackgroundColor: AppColors.darkBackground,

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: AppButtonStyles.elevatedButton,
    ),
    textButtonTheme: TextButtonThemeData(style: AppButtonStyles.textButton),

   
  );
}
