import 'package:flutter/material.dart';

/// Central color palette for the app.
/// Modern gradient + playful theme.
class AppColors {
  AppColors._();

  // Brand colors
  static const Color primary = Color(0xFF6C4DFF);
  static const Color primaryDark = Color(0xFF4B2EE0);
  static const Color secondary = Color(0xFFFF5C8A);
  static const Color accent = Color(0xFFFFB23E);

  // Backgrounds and surfaces
  static const Color background = Color(0xFFF6F5FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFEEEBFF);

  // Text
  static const Color textPrimary = Color(0xFF1B1340);
  static const Color textSecondary = Color(0xFF6B6685);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Answer states
  static const Color correct = Color(0xFF2BCB7C);
  static const Color wrong = Color(0xFFFF4D5E);

  // Main brand gradient (used on buttons, headers, login)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Distinct gradient per category card, picked by index.
  static const List<List<Color>> categoryGradients = [
    [Color(0xFF6C4DFF), Color(0xFF9C7BFF)], // violet
    [Color(0xFFFF5C8A), Color(0xFFFF9A6C)], // pink-orange
    [Color(0xFF2BCB7C), Color(0xFF54E0B0)], // green
    [Color(0xFF3EA0FF), Color(0xFF6CD8FF)], // blue
    [Color(0xFFFFB23E), Color(0xFFFFD36C)], // amber
    [Color(0xFFFF6CC4), Color(0xFFC56CFF)], // magenta
  ];

  /// Returns a gradient color pair for a category at [index].
  /// Wraps around when there are more categories than gradients.
  static List<Color> gradientForIndex(int index) {
    final int safeIndex = index % categoryGradients.length;
    return categoryGradients[safeIndex];
  }
}
