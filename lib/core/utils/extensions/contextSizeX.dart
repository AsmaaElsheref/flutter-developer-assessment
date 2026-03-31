
import 'package:flutter/material.dart';

extension ContextSizeX on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenHeight => MediaQuery.sizeOf(this).height;
  double get screenWidth  => MediaQuery.sizeOf(this).width;
}
