import 'package:flutter/material.dart';
import 'package:near_vibe/core/themes/app_colors.dart';

extension ThemeColors on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  // PRIMARY
  Color get primary => Theme.of(this).colorScheme.primary;

  // SECONDARY
  Color get secondary =>
      isDarkMode ? AppColors.darkSecondary : AppColors.lightSecondary;

  // BACKGROUND
  Color get background =>
      isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;

  // SURFACE
  Color get surface =>
      isDarkMode ? AppColors.darkSurface : AppColors.lightSurface;

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

  Color get warning => AppColors.warning;
}
