import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppButtonStyles {
  static final elevatedButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    elevation: 0,
    padding: const EdgeInsets.symmetric(vertical: 18),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  );

  static final textButton = TextButton.styleFrom(
    foregroundColor: AppColors.primary,
    padding: const EdgeInsets.symmetric(vertical: 18),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: const BorderSide(color: AppColors.primary, width: 1.5),
    ),
  );
}
