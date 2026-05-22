import 'package:flutter/material.dart';
import 'package:near_vibe/core/themes/theme_extensions.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  final bool scrollable;
  final EdgeInsetsGeometry? padding;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;

  const AppScaffold({
    super.key,
    required this.child,
    this.scrollable = false,
    this.padding,
    this.appBar,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: child,
    );

    return Scaffold(
      backgroundColor: context.background,
      appBar: appBar,
      floatingActionButton: floatingActionButton,

      body: SafeArea(
        child: scrollable ? SingleChildScrollView(child: content) : content,
      ),
    );
  }
}
