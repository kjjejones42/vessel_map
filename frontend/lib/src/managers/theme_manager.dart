import 'package:flutter/material.dart';

class ThemeManager {
  static const Color themeColor = Colors.blue;

  static ThemeData createTheme(Brightness brightness) {
    ColorScheme colorScheme =
        ColorScheme.fromSeed(seedColor: themeColor, brightness: brightness);
    return ThemeData(
        brightness: brightness,
        colorScheme: colorScheme,
        appBarTheme: AppBarTheme(
            foregroundColor: colorScheme.onPrimaryContainer,
            backgroundColor: colorScheme.primaryContainer));
  }
}
