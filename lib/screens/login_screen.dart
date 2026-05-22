import 'package:flutter/material.dart';
import 'package:near_vibe/core/responsive/responsive.dart';
import 'package:near_vibe/core/themes/app_text_styles.dart';
import 'package:near_vibe/core/themes/theme_extensions.dart';
import 'package:near_vibe/core/utils/validators.dart';
import 'package:near_vibe/core/widgets/app_scaffold.dart';
import 'package:near_vibe/core/widgets/app_snackbar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void onLogin() {
    if (_formKey.currentState!.validate()) {
      AppSnackBar.success(context, "Login Success");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      scrollable: true,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: context.res.hlg),
            Text(
              "Login",
              style: AppTextStyles.headlineLarge.copyWith(
                color: context.primary,
              ),
            ),
            SizedBox(height: context.res.hlg),
            TextFormField(
              controller: emailController,
              validator: AppValidator.email,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: "Email"),
            ),
            SizedBox(height: context.res.hsm),
            TextFormField(
              controller: passwordController,
              validator: AppValidator.password,
              obscureText: true,
              keyboardType: TextInputType.visiblePassword,
              decoration: InputDecoration(labelText: "Password"),
            ),
            SizedBox(height: context.res.hmd),
            ElevatedButton(
              onPressed: onLogin,
              child: Text("Login", style: AppTextStyles.titleMedium),
            ),
          ],
        ),
      ),
    );
  }
}
