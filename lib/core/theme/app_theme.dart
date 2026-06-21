import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    // We use a single pastel blue seed to let Material 3 generate the full tonal palette
    const Color seedColor = Color(0xFFB3C8CF);
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
      ),
      // We rely entirely on the native M3 defaults for shape, typography, and color mappings.
    );
  }
}
