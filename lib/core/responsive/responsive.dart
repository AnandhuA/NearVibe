import 'package:flutter/material.dart';

extension ResponsiveExtension on BuildContext {
  Responsive get res => Responsive(this);
}

class Responsive {
  final BuildContext context;

  Responsive(this.context);

  double get width => MediaQuery.of(context).size.width;
  double get height => MediaQuery.of(context).size.height;

  // DESIGN SIZE
  static const double designWidth = 375;
  static const double designHeight = 812;

  // ----  ORIENTATION ----------
  bool get isPortrait =>
      MediaQuery.of(context).orientation == Orientation.portrait;

  bool get isLandscape =>
      MediaQuery.of(context).orientation == Orientation.landscape;
  // --------- DEVICE TYPE (shortest side = reliable on all orientations) ----------
  double get shortestSide => MediaQuery.of(context).size.shortestSide;

  bool get isMobile => shortestSide < 600;
  bool get isTablet => shortestSide >= 600 && shortestSide < 1024;
  bool get isDesktop => shortestSide >= 1024;

  // ---- width percentage --------
  double w(double percent) => width * percent;

  // ----------- height percentage ------------
  double h(double percent) => height * percent;

  // FONT SCALE
  double scaleText(double size) {
    double scale = width / designWidth;

    // Prevent too small or too large text
    scale = scale.clamp(0.85, 1.25);

    return size * scale;
  }


  // --------- RESPONSIVE VALUE PICKER ----------
  T responsive<T>({required T mobile, T? tablet, T? desktop}) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }

  // ---WIDTH SPACING (horizontal spacing)

  double get wxs => width * 0.02;
  double get wsm => width * 0.04;
  double get wmd => width * 0.06;
  double get wlg => width * 0.10;

  //  HEIGHT SPACING (vertical spacing)

  double get hxs => height * 0.01;
  double get hsm => height * 0.02;
  double get hmd => height * 0.04;
  double get hlg => height * 0.06;
}
