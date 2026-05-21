import 'package:flutter/material.dart';
import 'package:near_vibe/core/themes/app_colors.dart';

class AppTheme {
  //-------------------Light Theme--------------------------
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.lightPrimary,
    scaffoldBackgroundColor: AppColors.lightBackground,
  );

  //-------------------Dark Theme--------------------------
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.darkPrimary,
    scaffoldBackgroundColor: AppColors.darkBackground,
  );
}
