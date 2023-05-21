import 'package:flutter/material.dart';

class Rhombus extends ShapeBorder {
  const Rhombus();

  @override
  EdgeInsetsGeometry get dimensions {
    return const EdgeInsets.only();
  }

  @override
  Path getInnerPath(Rect rect, { TextDirection? textDirection }) {
    return getOuterPath(rect, textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, { TextDirection? textDirection }) {
    return Path()
      ..moveTo(rect.width / 2.0, rect.top)
      ..lineTo(rect.right, rect.height / 2.0)
      ..lineTo(rect.width / 2.0, rect.bottom)
      ..lineTo(rect.left, rect.height / 2.0)
      ..lineTo(rect.width / 2.0, rect.top)
      ..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, { TextDirection? textDirection }) {}

  // This border doesn't support scaling.
  @override
  ShapeBorder scale(double t) {
    return Rhombus();
  }
}
