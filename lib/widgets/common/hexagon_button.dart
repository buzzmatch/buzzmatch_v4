import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_styles.dart';
import 'hexagon_clipper.dart';

class HexagonButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final double size;
  final Color color;
  final Color textColor;
  final double fontSize;
  final bool isSelected;
  
  const HexagonButton({
    Key? key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.size = 120.0,
    this.color = AppColors.primary,
    this.textColor = Colors.white,
    this.fontSize = 14.0,
    this.isSelected = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: size,
            height: size * 0.866, // Height of a hexagon is width * 0.866
            decoration: BoxDecoration(
              boxShadow: isSelected ? [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ] : [],
            ),
            child: ClipPath(
              clipper: HexagonClipper(),
              child: Container(
                color: isSelected ? color.darken(10) : color,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(
                          icon,
                          color: textColor,
                          size: size * 0.3,
                        ),
                        const SizedBox(height: 8),
                      ],
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textColor,
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension on Color {
  darken(int i) {}
}