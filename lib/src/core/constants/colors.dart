import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color emeraldGreen = Color(0xFF2ECC71);
  static const Color mintGreen = Color(0xFFA7D9B4);

  // Secondary colors
  static const Color lightGrey = Color(0xFFECF0F1);
  static const Color darkGrey = Color(0xFF34495E);
  static const Color charCoal = Color(0xFF2C3E50);

  // Accent colors
  static const Color accentBlue = Color(0xFF3498DB);
  static const Color accentPurple = Color(0xFF9B59B6);

  // Glassmorphic colors
  static final Color glassBackgroundLight = Colors.white.withOpacity(0.12);
  static final Color glassBackgroundDark = Colors.black.withOpacity(0.25);
  static final Color glassBorderLight = Colors.white.withOpacity(0.18);
  static final Color glassBorderDark = Colors.white.withOpacity(0.08);

  // Background gradients
  static const List<Color> dayGradient = [
    Color(0xFFE0F7FA), // Light cyan
    Color(0xFF80CBC4), // Teal
    Color(0xFF4DB6AC), // Darker teal
  ];

  static const List<Color> nightGradient = [
    Color(0xFF0F2027), // Deep blue-black
    Color(0xFF203A43), // Slate blue
    Color(0xFF2C5364), // Dark teal
  ];

  static const List<Color> twilightGradient = [
    Color(0xFF2C3E50), // Charcoal
    Color(0xFFFD746C), // Soft coral/sunset
  ];

  static const List<Color> sunriseGradient = [
    Color(0xFFF3904F), // Sunrise orange
    Color(0xFF3B4371), // Sunrise purple
  ];
}
