import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_images.dart';
import '../../constants/app_styles.dart';
import '../../widgets/common/hexagon_button.dart';
import '../../services/language_service.dart';
import 'welcome_controller.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WelcomeController());
    final languageService = Get.find<LanguageService>();
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Language switch button
              Align(
                alignment: Alignment.topRight,
                child: Obx(() => TextButton.icon(
                  onPressed: () => controller.toggleLanguage(),
                  icon: const Icon(Icons.language, color: AppColors.primary),
                  label: Text(
                    languageService.isArabic ? 'English' : 'العربية',
                    style: AppStyles.body2.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )),
              ),
              
              const SizedBox(height: 40),
              
              // App logo
              Image.asset(
                AppImages.logo,
                width: 120,
                height: 120,
              ),
              
              const SizedBox(height: 24),
              
              // Welcome message
              Text(
                'welcome'.tr,
                style: AppStyles.heading1.copyWith(
                  fontSize: 28,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 12),
              
              // Subtitle
              Text(
                'select_user_type'.tr,
                style: AppStyles.body1.copyWith(
                  color: AppColors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              
              const Spacer(),
              
              // User type selection
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Brand button
                  Column(
                    children: [
                      HexagonButton(
                        label: 'brand'.tr,
                        icon: Icons.business,
                        size: 130,
                        onPressed: () => controller.navigateToAuth('brand'),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'brand_description'.tr,
                        style: AppStyles.caption,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  
                  // Content Creator button
                  Column(
                    children: [
                      HexagonButton(
                        label: 'content_creator'.tr,
                        icon: Icons.camera_alt,
                        size: 130,
                        onPressed: () => controller.navigateToAuth('creator'),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'creator_description'.tr,
                        style: AppStyles.caption,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              ),
              
              const Spacer(),
              
            ],
          ),
        ),
      ),
    );
  }
}