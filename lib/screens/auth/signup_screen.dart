import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_styles.dart';
import '../../constants/app_constants.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import 'auth_controller.dart';

class SignupScreen extends StatelessWidget {
  final AuthController controller = Get.find<AuthController>();
  
  SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get user type from arguments
    final Map<String, dynamic> args = Get.arguments ?? {'userType': 'brand'};
    final String userType = args['userType'];
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('signup'.tr),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: controller.signupFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  userType == 'brand' 
                      ? 'Sign Up as Brand' 
                      : 'Sign Up as Content Creator',
                  style: AppStyles.heading2,
                ),
                
                const SizedBox(height: 8),
                
                // Subtitle
                Text(
                  'Create your account to get started',
                  style: AppStyles.body2.copyWith(color: AppColors.grey),
                ),
                
                const SizedBox(height: 32),
                
                // Fields based on user type
                if (userType == 'brand') _buildBrandFields(),
                if (userType == 'creator') _buildCreatorFields(),
                
                const SizedBox(height: 32),
                
                // Password and Confirm Password fields
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
                
                const SizedBox(height: 20),
                
                Obx(() => CustomTextField(
                  label: 'confirm_password'.tr,
                  hint: '••••••••',
                  controller: controller.confirmPasswordController,
                  obscureText: !controller.showConfirmPassword.value,
                  prefixIcon: Icons.lock_outline,
                  suffix: IconButton(
                    icon: Icon(
                      controller.showConfirmPassword.value 
                          ? Icons.visibility_off 
                          : Icons.visibility,
                      color: AppColors.grey,
                    ),
                    onPressed: () => controller.toggleConfirmPasswordVisibility(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirm password is required';
                    }
                    if (value != controller.passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  readOnly: false,
                )),
                
                const SizedBox(height: 32),
                
                // Sign up button
                Obx(() => CustomButton(
                  label: 'signup'.tr,
                  onPressed: () => controller.signup(userType),
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
                
                // Login link
                Align(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'already_have_account'.tr,
                        style: AppStyles.body2,
                      ),
                      TextButton(
                        onPressed: () => controller.navigateToLogin(userType),
                        child: Text(
                          'login'.tr,
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
  
  Widget _buildBrandFields() {
    return Column(
      children: [
        // Company Name
        CustomTextField(
          label: 'company_name'.tr,
          hint: 'Your company name',
          controller: controller.companyNameController,
          prefixIcon: Icons.business,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Company name is required';
            }
            return null;
          },
          readOnly: false,
        ),
        
        const SizedBox(height: 20),
        
        // Email
        CustomTextField(
          label: 'email'.tr,
          hint: 'company@example.com',
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
        
        // Phone
        CustomTextField(
          label: 'phone'.tr,
          hint: '+966 XX XXX XXXX',
          controller: controller.phoneController,
          keyboardType: TextInputType.phone,
          prefixIcon: Icons.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Phone number is required';
            }
            return null;
          },
          readOnly: false,
        ),
        
        const SizedBox(height: 20),
        
        // Business Category dropdown
        CustomTextField(
          label: 'business_category'.tr,
          hint: 'Select business category',
          controller: controller.businessCategoryController,
          prefixIcon: Icons.category,
          suffix: DropdownButtonHideUnderline(
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton<String>(
                isDense: true,
                icon: const Icon(Icons.arrow_drop_down),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    controller.businessCategoryController.text = newValue;
                  }
                },
                items: AppConstants.businessCategories
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Business category is required';
            }
            return null;
          },
          readOnly: false,
        ),
        
        const SizedBox(height: 20),
        
        // Country
        CustomTextField(
          label: 'country'.tr,
          hint: 'Your country',
          controller: controller.countryController,
          prefixIcon: Icons.location_on_outlined,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Country is required';
            }
            return null;
          },
          readOnly: false,
        ),
      ],
    );
  }
  
  Widget _buildCreatorFields() {
    return Column(
      children: [
        // Full Name
        CustomTextField(
          label: 'full_name'.tr,
          hint: 'Your full name',
          controller: controller.fullNameController,
          prefixIcon: Icons.person_outline,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Full name is required';
            }
            return null;
          },
          readOnly: false,
        ),
        
        const SizedBox(height: 20),
        
        // Email
        CustomTextField(
          label: 'email'.tr,
          hint: 'your.email@example.com',
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
        
        // Phone
        CustomTextField(
          label: 'phone'.tr,
          hint: '+966 XX XXX XXXX',
          controller: controller.phoneController,
          keyboardType: TextInputType.phone,
          prefixIcon: Icons.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Phone number is required';
            }
            return null;
          },
          readOnly: false,
        ),
        
        const SizedBox(height: 20),
        
        // Content Type dropdown
        CustomTextField(
          label: 'content_type'.tr,
          hint: 'Select content type',
          controller: controller.contentTypeController,
          prefixIcon: Icons.video_library,
          suffix: DropdownButtonHideUnderline(
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton<String>(
                isDense: true,
                icon: const Icon(Icons.arrow_drop_down),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    controller.contentTypeController.text = newValue;
                  }
                },
                items: AppConstants.contentTypes
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Content type is required';
            }
            return null;
          },
          readOnly: false,
        ),
        
        const SizedBox(height: 20),
        
        // Main Category dropdown
        CustomTextField(
          label: 'main_category'.tr,
          hint: 'Select main category',
          controller: controller.mainCategoryController,
          prefixIcon: Icons.category,
          suffix: DropdownButtonHideUnderline(
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton<String>(
                isDense: true,
                icon: const Icon(Icons.arrow_drop_down),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    controller.mainCategoryController.text = newValue;
                  }
                },
                items: AppConstants.creatorCategories
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Main category is required';
            }
            return null;
          },
          readOnly: false,
        ),
        
        const SizedBox(height: 20),
        
        // Country
        CustomTextField(
          label: 'country'.tr,
          hint: 'Your country',
          controller: controller.countryController,
          prefixIcon: Icons.location_on_outlined,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Country is required';
            }
            return null;
          },
          readOnly: false,
        ),
      ],
    );
  }
}