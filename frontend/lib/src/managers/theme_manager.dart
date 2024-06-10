import 'package:flutter/material.dart';

/// Creates the app theme, both light and dark.
class ThemeManager {
  static const Color themeColor = Color.fromARGB(255, 33, 150, 243);

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
