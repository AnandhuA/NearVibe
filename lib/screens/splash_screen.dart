import 'package:flutter/material.dart';
import 'package:near_vibe/core/responsive/responsive.dart';
import 'package:near_vibe/core/themes/app_text_styles.dart';
import 'package:near_vibe/core/themes/theme_extensions.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: .center,

          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "NearVibe",
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineLarge.copyWith(
                color: context.primary,
              ),
            ),
            SizedBox(height: context.res.hsm),
            Text(
              "Discover What's happening\nnear you, right now",
              style: AppTextStyles.titleLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.res.hlg),
            ElevatedButton(
              onPressed: () {},
              child: Text(
                "Get Started",
                style: TextStyle(color: context.whiteText),
              ),
            ),

            SizedBox(height: context.res.hxs),

            TextButton(onPressed: () {}, child: Text("I have an account")),
          ],
        ),
      ),
    );
  }
}
