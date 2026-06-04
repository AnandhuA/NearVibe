import 'package:flutter/material.dart';
import 'package:near_vibe/core/themes/app_colors.dart';

extension ThemeColors on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  // PRIMARY
  Color get primary =>
      isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary;

  // SECONDARY
  Color get secondary =>
      isDarkMode ? AppColors.darkSecondary : AppColors.lightSecondary;

  // BACKGROUND
  Color get background =>
      isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;

  // TEXT
  Color get text => isDarkMode ? AppColors.darkText : AppColors.lightText;

  //HIT TEXT

  Color get hitText =>
      isDarkMode ? AppColors.darkHintText : AppColors.lightHintText;

  //loading color

Color get loadingColor => isDarkMode ? AppColors.darkLoadingColor:AppColors.lightLoadingColor;
  // COMMON

  Color get whiteText => AppColors.whiteText;

  Color get darkText => AppColors.blackText;

  Color get success => AppColors.success;

  Color get error => AppColors.error;
}
