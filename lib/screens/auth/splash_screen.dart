import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:near_vibe/core/responsive/responsive.dart';
import 'package:near_vibe/core/themes/app_colors.dart';
import 'package:near_vibe/screens/auth/landing_screen.dart';
import 'package:near_vibe/screens/layout/main_layout.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            user != null ? const MainLayoutScreen() : const LandingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on, size: 80),
            SizedBox(height: context.res.hsm),
            SpinKitThreeBounce(color: AppColors.loadingColor, size: 18),
          ],
        ),
      ),
    );
  }
}
