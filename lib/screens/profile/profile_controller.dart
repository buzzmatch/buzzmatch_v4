import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/brand_model.dart';
import '../../models/creator_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../constants/app_constants.dart';
import '../../routes/app_pages.dart';

class ProfileController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  
  // Observable variables
  final RxBool isLoading = true.obs;
  final RxString userType = ''.obs;
  
  // User data
  final Rx<BrandModel?> brand = Rx<BrandModel?>(null);
  final Rx<CreatorModel?> creator = Rx<CreatorModel?>(null);
  
  // Statistics
  final RxInt campaignsCount = 0.obs;
  final RxInt collaborationsCount = 0.obs;
  final RxInt completedCount = 0.obs;
  
  @override
  void onInit() {
    super.onInit();
    
    // Determine user type
    userType.value = _authService.currentUser.value?.userType ?? '';
    
    loadProfileData();
  }
  
  Future<void> loadProfileData() async {
    try {
      isLoading.value = true;
      
      if (userType.value == AppConstants.userTypeBrand) {
        // Load brand data
        brand.value = _authService.currentBrand.value;
        
        if (brand.value != null) {
          // Load campaigns count
          final campaignDocs = await _firestoreService.getBrandCampaigns(brand.value!.id);
          campaignsCount.value = campaignDocs.length;
          
          // Load collaborations count
          final collaborationDocs = await _firestoreService.getBrandCollaborations(brand.value!.id);
          collaborationsCount.value = collaborationDocs.length;
          
          // Count completed collaborations
          completedCount.value = collaborationDocs
              .where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return data['status'] == AppConstants.statusCompleted;
              })
              .length;
        }
      } else {
        // Load creator data
        creator.value = _authService.currentCreator.value;
        
        if (creator.value != null) {
          // Load collaborations count
          final collaborationDocs = await _firestoreService.getCreatorCollaborations(creator.value!.id);
          collaborationsCount.value = collaborationDocs.length;
          
          // Count completed collaborations
          completedCount.value = collaborationDocs
              .where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return data['status'] == AppConstants.statusCompleted;
              })
              .length;
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load profile data: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
  
  void navigateToEditProfile() {
    Get.toNamed(Routes.PROFILE_EDIT);
  }
  
  void navigateToSettings() {
    Get.toNamed('/settings');
  }
  
  void showLogoutConfirmation() {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              logout();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
  
  Future<void> logout() async {
    try {
      await _authService.signOut();
      // Navigation will be handled by auth service
    } catch (e) {
      Get.snackbar('Error', 'Failed to logout: ${e.toString()}');
    }
  }
  
  Future<void> openUrl(String url) async {
    try {
      // Ensure URL has proper scheme
      Uri uri = Uri.parse(url);
      if (!url.startsWith('http')) {
        uri = Uri.parse('https://$url');
      }
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar('Error', 'Could not open the URL');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to open URL: ${e.toString()}');
    }
  }
  
  void viewPortfolioItem(String url) {
    Get.toNamed(
      '/image-viewer',
      arguments: {'url': url},
    );
  }
}