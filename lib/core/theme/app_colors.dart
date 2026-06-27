import 'package:flutter/material.dart';

/// Central color palette for the app.
/// Bold sunset identity: indigo to magenta to coral, with a lime accent.
class AppColors {
  AppColors._();

  // Brand colors
  static const Color primary = Color(0xFF7A3CF0); // vivid violet
  static const Color primaryDark = Color(0xFF4A2FBD);
  static const Color secondary = Color(0xFFE5328A); // hot magenta
  static const Color coral = Color(0xFFFF7A4D);
  static const Color accent = Color(0xFFDDFF4F); // electric lime

  // Backgrounds and surfaces
  static const Color background = Color(0xFFF5F3FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFEDE9FF);

  // Text
  static const Color textPrimary = Color(0xFF1B1140);
  static const Color textSecondary = Color(0xFF6B6691);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Answer states
  static const Color correct = Color(0xFF2BCB7C);
  static const Color wrong = Color(0xFFFF4D5E);

  // Signature three-stop gradient for backgrounds, headers and login.
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF5A2BE0), Color(0xFFD62E8A), Color(0xFFFF7A4D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Two-stop gradient for buttons and compact surfaces.
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Distinct gradient per category card, picked by index.
  static const List<List<Color>> categoryGradients = [
    [Color(0xFF6A2CE0), Color(0xFFA05BFF)], // violet
    [Color(0xFFE5328A), Color(0xFFFF6FA3)], // pink
    [Color(0xFFFF6B4D), Color(0xFFFFA24D)], // coral-orange
    [Color(0xFF1FC8C8), Color(0xFF4DE0C0)], // teal
    [Color(0xFF3A6BFF), Color(0xFF6FA8FF)], // blue
    [Color(0xFF5BD13C), Color(0xFFA8E84D)], // lime-green
  ];

  /// Returns a gradient color pair for a category at [index].
  /// Wraps around when there are more categories than gradients.
  static List<Color> gradientForIndex(int index) {
    final int safeIndex = index % categoryGradients.length;
    return categoryGradients[safeIndex];
  }
}
