// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_images.dart';
import '../../constants/app_styles.dart';
import '../../controllers/splash_controller.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SplashController());
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo with honeycomb animation
            Lottie.asset(
              AppImages.honeycombAnimation,
              width: 200,
              height: 200,
              repeat: true,
              animate: true,
            ),
            
            const SizedBox(height: 24),
            
            // App name
            Text(
              'BuzzMatch',
              style: AppStyles.heading1.copyWith(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.dark,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Tagline
            Text(
              'Connect. Create. Collaborate.',
              style: AppStyles.body1.copyWith(
                color: AppColors.grey,
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Loading indicator
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SplashController {
}