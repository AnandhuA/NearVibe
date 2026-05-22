import 'package:flutter/material.dart';
import 'package:near_vibe/core/responsive/responsive.dart';
import 'package:near_vibe/core/style/app_text_styles.dart';
import 'package:near_vibe/core/themes/theme_extensions.dart';
import 'package:near_vibe/core/widgets/app_scaffold.dart';
import 'package:near_vibe/screens/auth/login_screen.dart';
import 'package:near_vibe/screens/auth/signup_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Column(
        mainAxisAlignment: .center,

        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "NearVibe",
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineLarge.copyWith(color: context.primary),
          ),
          SizedBox(height: context.res.hsm),
          Text(
            "Discover What's happening\nnear you, right now",
            style: AppTextStyles.titleLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.res.hlg),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SignupScreen()),
              );
            },
            child: Text("Get Started", style: AppTextStyles.titleMedium),
          ),

          SizedBox(height: context.res.hsm),

          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            child: Text("I have an account", style: AppTextStyles.titleMedium),
          ),
        ],
      ),
    );
  }
}
