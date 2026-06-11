import 'package:flutter/material.dart';
import 'package:near_vibe/core/responsive/responsive.dart';
import 'package:near_vibe/core/style/app_text_styles.dart';
import 'package:near_vibe/core/themes/theme_extensions.dart';

class LocationBottomSheet extends StatelessWidget {
  final Function(String location) onLocationSelected;
  final VoidCallback onPickFromMap;

  const LocationBottomSheet({
    super.key,
    required this.onLocationSelected,
    required this.onPickFromMap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Select Location",
            style: AppTextStyles.titleLarge,
          ),

          SizedBox(height: context.res.hsm),

          /// Current Location
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              onLocationSelected("Current Location");

              Navigator.pop(context);
            },
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
                    Icons.my_location_rounded,
                    color: context.primary,
                  ),

                  SizedBox(width: context.res.wsm),

                  Text(
                    "Use Current Location",
                    style: AppTextStyles.bodyLarge,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: context.res.hsm),

          /// Pick From Map
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.pop(context);

              onPickFromMap();
            },
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
                    Icons.map_rounded,
                    color: context.primary,
                  ),

                  SizedBox(width: context.res.wsm),

                  Text(
                    "Pick From Map",
                    style: AppTextStyles.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: context.res.hlg),
        ],
      ),
    );
  }
}