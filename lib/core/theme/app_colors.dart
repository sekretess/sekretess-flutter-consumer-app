import 'package:flutter/material.dart';

/// Sekretess branding colors
class AppColors {
  // Primary colors
  static const Color primaryBackground = Color(0xFF0D0D0D); // Dark background
  static const Color sekretessBlue = Color(0xFF003A9B); // Primary brand color
  static const Color white = Color(0xFFFFFFFF);
  
  // Secondary colors
  static const Color lightBlue600 = Color(0xFF039BE5);
  static const Color lightBlue900 = Color(0xFF01579B);
  static const Color lightBlueA200 = Color(0xFF40C4FF);
  static const Color lightBlueA400 = Color(0xFF00B0FF);
  
  // UI colors
  static const Color cardBackground = Color(0xFF1A1A1A);
  static const Color dividerColor = Color(0xFF2A2A2A);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textTertiary = Color(0xFF808080);
  
  // Status colors
  static const Color error = Color(0xFFFF5252);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  
  // Gradient colors for buttons
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [sekretessBlue, lightBlue600],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
