import 'package:flutter/material.dart';
import 'package:near_vibe/core/responsive/responsive.dart';
import 'package:near_vibe/core/style/app_text_styles.dart';
import 'package:near_vibe/core/themes/theme_extensions.dart';

class LocationPickerWidget extends StatelessWidget {
  final String? selectedLocation;
  final VoidCallback onTap;

  const LocationPickerWidget({
    super.key,
    required this.selectedLocation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: context.primary.withValues(alpha: 0.08),
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_on_rounded,
              color: context.primary,
            ),

            SizedBox(width: context.res.wsm),

            Expanded(
              child: Text(
                selectedLocation ??
                    "Search or pin on map",
                style: AppTextStyles.bodyLarge,
              ),
            ),

            Icon(
              Icons.keyboard_arrow_right_rounded,
              color: context.primary,
            ),
          ],
        ),
      ),
    );
  }
}