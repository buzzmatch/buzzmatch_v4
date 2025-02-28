import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_styles.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import 'auth_controller.dart';

class LoginScreen extends StatelessWidget {
  final AuthController controller = Get.put(AuthController());
  
  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get user type from arguments
    final Map<String, dynamic> args = Get.arguments ?? {'userType': 'brand'};
    final String userType = args['userType'];
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('login'.tr),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: controller.loginFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  userType == 'brand' 
                      ? 'Login as Brand' 
                      : 'Login as Content Creator',
                  style: AppStyles.heading2,
                ),
                
                const SizedBox(height: 8),
                
                // Subtitle
                Text(
                  'Enter your credentials to continue',
                  style: AppStyles.body2.copyWith(color: AppColors.grey),
                ),
                
                const SizedBox(height: 32),
                // Email field
                CustomTextField(
                  label: 'email'.tr,
                  hint: 'example@email.com',
                  controller: controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    }
                    if (!GetUtils.isEmail(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  readOnly: false,
                ),
                
                const SizedBox(height: 20),
                
                // Password field
                Obx(() => CustomTextField(
                  label: 'password'.tr,
                  hint: '••••••••',
                  controller: controller.passwordController,
                  obscureText: !controller.showPassword.value,
                  prefixIcon: Icons.lock_outline,
                  suffix: IconButton(
                    icon: Icon(
                      controller.showPassword.value 
                          ? Icons.visibility_off 
                          : Icons.visibility,
                      color: AppColors.grey,
                    ),
                    onPressed: () => controller.togglePasswordVisibility(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  readOnly: false,
                )),
                
                const SizedBox(height: 16),
                
                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => controller.forgotPassword(),
                    child: Text(
                      'forgot_password'.tr,
                      style: AppStyles.body2.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Login button
                Obx(() => CustomButton(
                  label: 'login'.tr,
                  onPressed: () => controller.login(userType),
                  isLoading: controller.isLoading.value,
                )),
                
                const SizedBox(height: 24),
                
                // OR divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'or'.tr,
                        style: AppStyles.body2.copyWith(color: AppColors.grey),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Social login buttons
                Row(
                  children: [
                    // Google button
                    Expanded(
                      child: CustomButton(
                        label: 'Google',
                        onPressed: () => controller.signInWithGoogle(userType),
                        isOutlined: true,
                        icon: Icons.g_mobiledata,
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Apple button
                    Expanded(
                      child: CustomButton(
                        label: 'Apple',
                        onPressed: () => controller.signInWithApple(userType),
                        isOutlined: true,
                        icon: Icons.apple,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Sign up link
                Align(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'dont_have_account'.tr,
                        style: AppStyles.body2,
                      ),
                      TextButton(
                        onPressed: () => controller.navigateToSignup(userType),
                        child: Text(
                          'signup'.tr,
                          style: AppStyles.body2.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}