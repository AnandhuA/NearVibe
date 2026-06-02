import 'package:flutter/material.dart';
import 'package:near_vibe/core/style/app_text_styles.dart';
import 'package:near_vibe/core/themes/theme_extensions.dart';
import 'package:near_vibe/core/widgets/app_scaffold.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: context.primary,
            child: Text("A", style: AppTextStyles.headlineLarge),
          ),
          Text(
            "Anandhu",
            style: AppTextStyles.headlineLarge,
            textAlign: TextAlign.center,
          ),
          Text(
            "Kochi,Kerala Joined 2022",
            style: AppTextStyles.bodyLarge.copyWith(color: context.hitText),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
