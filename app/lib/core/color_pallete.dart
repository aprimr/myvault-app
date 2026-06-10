import 'dart:math';
import 'package:flutter/material.dart';

class ColorPallete {
  ColorPallete._();

  static const List<Color> palette = [
    Color(0xFF00ACC1), // Soft Cyan
    Color(0xFFE91E63), // Soft Pink
    Color(0xFF66BB6A), // Soft Green
    Color(0xFFEF5350), // Soft Red
    Color(0xFF42A5F5), // Soft Blue
    Color(0xFF7E57C2), // Soft Purple
    Color(0xFFFB8C00), // Soft Orange
    Color(0xFF5C6BC0), // Indigo Soft
    Color(0xFFFDD835), // Soft Yellow (muted)
    Color(0xFF26A69A), // Soft Teal
    Color(0xFFA1887F), // Soft Brown
    Color(0xFF9CCC65), // Soft Lime (muted)
  ];

  static Color byIndex(int index) {
    return palette[index % palette.length];
  }

  static Color random() {
    return palette[Random().nextInt(palette.length)];
  }
}
