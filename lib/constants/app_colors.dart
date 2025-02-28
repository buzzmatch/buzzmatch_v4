import 'package:flutter/material.dart';

class AppColors {
  // Primary brand colors
  static const Color primary = Color(0xFFFFB100);
  static const Color secondary = Color(0xFF004D40);
  
  // Background colors
  static const Color background = Color(0xFFFDF5D9); // Light beige (bee-inspired)
  static const Color cardBackground = Colors.white;
  
  // Text colors
  static const Color dark = Color(0xFF212121);
  static const Color grey = Color(0xFF757575);
  static const Color lightGrey = Color(0xFFBDBDBD);
  
  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  
  // Gradient colors
  static const List<Color> primaryGradient = [
    Color(0xFFFFB100),
    Color(0xFFFF9000),
  ];
  
  // Other UI elements
  static const Color divider = Color(0xFFE0E0E0);
  static const Color shadow = Color(0x1A000000);
}