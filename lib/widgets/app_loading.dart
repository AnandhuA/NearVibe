import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:near_vibe/core/themes/theme_extensions.dart';

SpinKitThreeBounce threeBounceLoading(BuildContext context) {
  return SpinKitThreeBounce(color: context.loadingColor, size: 18);
}
