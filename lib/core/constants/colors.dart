import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF6C63FF);
  static const Color secondary = Color(0xFFFF6584);
  static const Color success = Color(0xFF00C853);
  static const Color warning = Color(0xFFFFB74D);
  static const Color error = Color(0xFFFF5722);
  
  // Background Colors
  static const Color background = Color(0xFF0D0D1A);
  static const Color surface = Color(0xFF1A1A2E);
  static const Color surfaceVariant = Color(0xFF16213E);
  static const Color cardBackground = Color(0xFF252545);
  
  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textTertiary = Color(0xFF707070);
  static const Color textDisabled = Color(0xFF4A4A4A);
  
  // Habit Colors
  static const List<Color> habitColors = [
    Color(0xFF6C63FF), // Purple
    Color(0xFFFF6584), // Pink
    Color(0xFF4ECDC4), // Teal
    Color(0xFFFFE066), // Yellow
    Color(0xFF95E1D3), // Mint
    Color(0xFFFF8A65), // Orange
    Color(0xFF81C784), // Green
    Color(0xFF64B5F6), // Blue
    Color(0xFFBA68C8), // Light Purple
    Color(0xFFF06292), // Light Pink
    Color(0xFFFFB74D), // Amber
    Color(0xFF4DB6AC), // Teal Green
  ];
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF9C88FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF00C853), Color(0xFF4CAF50)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF252545), Color(0xFF1A1A2E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // Glass Effect Colors
  static const Color glassColor = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  
  // Shadow Colors
  static const Color shadowColor = Color(0x40000000);
  static const Color cardShadow = Color(0x1A6C63FF);
  
  // Chart Colors
  static const List<Color> chartColors = [
    Color(0xFF6C63FF),
    Color(0xFFFF6584),
    Color(0xFF4ECDC4),
    Color(0xFFFFE066),
    Color(0xFF95E1D3),
    Color(0xFFFF8A65),
  ];
}