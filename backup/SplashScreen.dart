import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      duration: const Duration(seconds: 3), // Animation duration: 2-3 seconds
      vsync: this,
    );

    // Define the animation curve
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    // Start the animation
    _controller.forward().then((_) {
      // Navigate to the Welcome Screen after the animation completes
     Get.offNamed('/welcome'); // Ensure you define the route in GetMaterialApp
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose of the animation controller to free resources
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF5D9), // Light beige background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the BuzzMatch logo
            Image.asset(
              'assets/images/logo.png', // Replace with your logo path
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 20),
            // Honeycomb animation effect
AnimatedBuilder(
  animation: _animation,
  builder: (context, child) {
    // Debugging: Print the current animation value
    print('Animation Value: ${_animation.value}');

    return CustomPaint(
      size: const Size(200, 200), // Adjust the size of the honeycomb effect
      painter: HoneycombPainter(animationValue: _animation.value),
    );
  },
),
          ],
        ),
      ),
    );
  }
}

// Custom Painter for Honeycomb Animation
class HoneycombPainter extends CustomPainter {
  final double animationValue;

  HoneycombPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint hexagonPaint = Paint()
      ..color = Colors.yellow.withOpacity(0.8) // Yellow color for the honeycomb
      ..style = PaintingStyle.fill;

    final Path hexagonPath = Path();

    // Draw multiple hexagons in a wave-like pattern
    for (int i = 0; i < 6; i++) {
      double angle = (i * (2 * 3.14159 / 6)); // Angle for each hexagon vertex
      double radius = 50 + (animationValue * 50); // Animate the radius outward
      Offset center = Offset(size.width / 2, size.height / 2);

      // Calculate the vertices of the hexagon
      Offset vertex = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );

      if (i == 0) {
        hexagonPath.moveTo(vertex.dx, vertex.dy);
      } else {
        hexagonPath.lineTo(vertex.dx, vertex.dy);
      }
    }

    hexagonPath.close();
    canvas.drawPath(hexagonPath, hexagonPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Repaint on every frame for animation
  }
}