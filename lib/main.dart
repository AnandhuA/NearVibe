import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:near_vibe/core/themes/app_theme.dart';
import 'package:near_vibe/firebase_options.dart';
import 'package:near_vibe/providers/auth_provider.dart';
import 'package:near_vibe/providers/map_providers.dart';
import 'package:near_vibe/providers/user_provider.dart';
import 'package:near_vibe/screens/auth/splash_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MapProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: SplashScreen(),
      ),
    );
  }
}
