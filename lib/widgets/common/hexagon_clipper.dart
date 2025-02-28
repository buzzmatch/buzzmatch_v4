import 'package:flutter/material.dart';
import 'dart:math' as math;

class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    final double width = size.width;
    final double height = size.height;
    final double centerX = width / 2;
    final double centerY = height / 2;
    
    // Calculate hexagon corner points
    final double radius = math.min(width / 2, height / 2);
    
    // Start at the right-most point
    path.moveTo(centerX + radius, centerY);
    
    // Draw the six sides of the hexagon
    for (int i = 1; i <= 6; i++) {
      final double x = centerX + radius * math.cos(i * 2 * math.pi / 6);
      final double y = centerY + radius * math.sin(i * 2 * math.pi / 6);
      path.lineTo(x, y);
    }
    
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}