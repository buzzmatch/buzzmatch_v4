import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/auth_service.dart';
import '../../routes/app_pages.dart';
import '../../constants/app_constants.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  
  // Form keys
  final loginFormKey = GlobalKey<FormState>();
  final signupFormKey = GlobalKey<FormState>();
  final forgotPasswordFormKey = GlobalKey<FormState>();
  
  // Controllers for login
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  // Controllers for signup - brand
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController businessCategoryController = TextEditingController();
  
  // Controllers for signup - creator
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController contentTypeController = TextEditingController();
  final TextEditingController mainCategoryController = TextEditingController();
  
  // Controllers for both
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  
  // Observable variables
  final RxBool isLoading = false.obs;
  final RxBool showPassword = false.obs;
  final RxBool showConfirmPassword = false.obs;
  
  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    companyNameController.dispose();
    businessCategoryController.dispose();
    fullNameController.dispose();
    contentTypeController.dispose();
    mainCategoryController.dispose();
    phoneController.dispose();
    countryController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
  
  // Toggle password visibility
  void togglePasswordVisibility() {
    showPassword.value = !showPassword.value;
  }
  
  void toggleConfirmPasswordVisibility() {
    showConfirmPassword.value = !showConfirmPassword.value;
  }
  
  // Navigate to login screen
  void navigateToLogin(String userType) {
    Get.toNamed('/login', arguments: {'userType': userType});
  }
  
  // Navigate to signup screen
  void navigateToSignup(String userType) {
    Get.toNamed('/signup', arguments: {'userType': userType});
  }
  
  // Login with email and password
  Future<void> login(String userType) async {
    if (!loginFormKey.currentState!.validate()) {
      return;
    }
    
    try {
      isLoading.value = true;
      
      final email = emailController.text.trim();
      final password = passwordController.text;
      
      final credential = await _authService.signInWithEmailAndPassword(
        email,
        password,
      );
      
      if (credential != null) {
        await _authService.getUserData();
        
        if (_authService.currentUser.value?.userType != userType) {
          Get.snackbar(
            'Error',
            'This account is not registered as a ${userType == AppConstants.userTypeBrand ? 'brand' : 'content creator'}.',
          );
          await _authService.signOut();
          isLoading.value = false;
          return;
        }
        
        if (userType == AppConstants.userTypeBrand) {
          Get.offAllNamed('/brand-dashboard');
        } else {
          Get.offAllNamed('/creator-dashboard');
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to login: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Sign up with email and password
  Future<void> signup(String userType) async {
    if (!signupFormKey.currentState!.validate()) {
      return;
    }
    
    try {
      isLoading.value = true;
      
      final email = emailController.text.trim();
      final password = passwordController.text;
      
      final credential = await _authService.createUserWithEmailAndPassword(
        email,
        password,
      );
      
      if (credential != null) {
        // Prepare user data based on user type
        final Map<String, dynamic> userData = {
          'email': email,
          'phone': phoneController.text.trim(),
          'country': countryController.text.trim(),
        };
        
        if (userType == AppConstants.userTypeBrand) {
          userData['companyName'] = companyNameController.text.trim();
          userData['businessCategory'] = businessCategoryController.text.trim();
        } else {
          userData['fullName'] = fullNameController.text.trim();
          userData['contentType'] = contentTypeController.text.trim();
          userData['mainCategory'] = mainCategoryController.text.trim();
        }
        
        // Create user data in Firestore
        await _authService.createUserData(
          userType: userType,
          userData: userData,
        );
        if (userType == AppConstants.userTypeBrand) {
          Get.offAllNamed('/brand-dashboard');
        } else {
          Get.offAllNamed('/creator-dashboard');
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to signup: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Sign in with Google
  Future<void> signInWithGoogle(String userType) async {
    try {
      isLoading.value = true;
      
      final credential = await _authService.signInWithGoogle();
      
      if (credential != null) {
        // Check if user exists
        await _authService.getUserData();
        
        if (_authService.currentUser.value == null) {
          // New user, create user data
          final email = credential.user?.email ?? '';
          
          // Show dialog to complete profile
          await Get.dialog(
            AlertDialog(
              title: const Text('Complete Your Profile'),
              content: const Text('Please complete your profile to continue.'),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
          
          // Navigate to a profile completion screen or collect data here
          // For simplicity, we'll use a default data set
          final Map<String, dynamic> userData = {
            'email': email,
            'phone': '',
            'country': 'Saudi Arabia',
          };
          
          if (userType == AppConstants.userTypeBrand) {
            userData['companyName'] = 'My Company';
            userData['businessCategory'] = AppConstants.businessCategories.first;
          } else {
            userData['fullName'] = credential.user?.displayName ?? 'Content Creator';
            userData['contentType'] = AppConstants.contentTypes.first;
            userData['mainCategory'] = AppConstants.creatorCategories.first;
          }
          
          // Create user data in Firestore
          await _authService.createUserData(
            userType: userType,
            userData: userData,
          );
        } else if (_authService.currentUser.value?.userType != userType) {
          // User exists but with wrong user type
          Get.snackbar(
            'Error',
            'This account is already registered as a ${_authService.currentUser.value?.userType == AppConstants.userTypeBrand ? 'brand' : 'content creator'}.',
          );
          await _authService.signOut();
          isLoading.value = false;
          return;
        }
        
        // Navigate to dashboard
        if (userType == AppConstants.userTypeBrand) {
          Get.offAllNamed('/brand-dashboard');
        } else {
          Get.offAllNamed('/creator-dashboard');
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to sign in with Google: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Sign in with Apple
  Future<void> signInWithApple(String userType) async {
    try {
      isLoading.value = true;
      
      final credential = await _authService.signInWithApple();
      
      if (credential != null) {
        // Similar logic as Google sign-in
        await _authService.getUserData();
        
        if (_authService.currentUser.value == null) {
          final email = credential.user?.email ?? '';
          
          await Get.dialog(
            AlertDialog(
              title: const Text('Complete Your Profile'),
              content: const Text('Please complete your profile to continue.'),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
          
          final Map<String, dynamic> userData = {
            'email': email,
            'phone': '',
            'country': 'Saudi Arabia',
          };
          
          if (userType == AppConstants.userTypeBrand) {
            userData['companyName'] = 'My Company';
            userData['businessCategory'] = AppConstants.businessCategories.first;
          } else {
            userData['fullName'] = credential.user?.displayName ?? 'Content Creator';
            userData['contentType'] = AppConstants.contentTypes.first;
            userData['mainCategory'] = AppConstants.creatorCategories.first;
          }
          
          await _authService.createUserData(
            userType: userType,
            userData: userData,
          );
        } else if (_authService.currentUser.value?.userType != userType) {
          Get.snackbar(
            'Error',
            'This account is already registered as a ${_authService.currentUser.value?.userType == AppConstants.userTypeBrand ? 'brand' : 'content creator'}.',
          );
          await _authService.signOut();
          isLoading.value = false;
          return;
        }
        if (userType == AppConstants.userTypeBrand) {
          Get.offAllNamed('/brand-dashboard');
        } else {
          Get.offAllNamed('/creator-dashboard');
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to sign in with Apple: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Forgot password
  void forgotPassword() {
    final TextEditingController emailCtrl = TextEditingController(text: emailController.text);
    
    Get.dialog(
      AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your email address to receive a password reset link.'),
            const SizedBox(height: 16),
            Form(
              key: forgotPasswordFormKey,
              child: TextFormField(
                controller: emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  if (!GetUtils.isEmail(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (forgotPasswordFormKey.currentState!.validate()) {
                Get.back();
                try {
                  await _authService.resetPassword(emailCtrl.text.trim());
                  Get.snackbar(
                    'Success',
                    'Password reset email sent. Check your inbox.',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                } catch (e) {
                  Get.snackbar(
                    'Error',
                    'Failed to send reset email: ${e.toString()}',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}