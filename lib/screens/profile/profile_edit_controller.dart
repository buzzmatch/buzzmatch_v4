import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/brand_model.dart';
import '../../models/creator_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';
import '../../constants/app_constants.dart';

class ProfileEditController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final StorageService _storageService = Get.find<StorageService>();
  
  // Form key
  final formKey = GlobalKey<FormState>();
  
  // Observable variables
  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxString userType = ''.obs;
  
  // User data
  final Rx<BrandModel?> brand = Rx<BrandModel?>(null);
  final Rx<CreatorModel?> creator = Rx<CreatorModel?>(null);
  
  // Profile image
  final Rx<File?> imageFile = Rx<File?>(null);
  
  // Form controllers - Common
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  
  // Form controllers - Brand
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController businessCategoryController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  
  // Form controllers - Creator
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController contentTypeController = TextEditingController();
  final TextEditingController mainCategoryController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  
  // Social links
  final RxList<String> socialLinks = <String>[].obs;
  
  // Portfolio
  final RxList<String> portfolioUrls = <String>[].obs;
  final RxList<File> portfolioFiles = <File>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    
    // Determine user type
    userType.value = _authService.currentUser.value?.userType ?? '';
    
    loadProfileData();
  }
  
  @override
  void onClose() {
    // Dispose controllers
    emailController.dispose();
    phoneController.dispose();
    countryController.dispose();
    
    companyNameController.dispose();
    businessCategoryController.dispose();
    websiteController.dispose();
    descriptionController.dispose();
    
    fullNameController.dispose();
    contentTypeController.dispose();
    mainCategoryController.dispose();
    bioController.dispose();
    
    super.onClose();
  }
  
  Future<void> loadProfileData() async {
    try {
      isLoading.value = true;
      
      if (userType.value == AppConstants.userTypeBrand) {
        // Load brand data
        brand.value = _authService.currentBrand.value;
        
        if (brand.value != null) {
          // Populate form fields
          companyNameController.text = brand.value!.companyName;
          businessCategoryController.text = brand.value!.businessCategory;
          emailController.text = brand.value!.email;
          phoneController.text = brand.value!.phone;
          countryController.text = brand.value!.country;
          websiteController.text = brand.value!.websiteUrl ?? '';
          descriptionController.text = brand.value!.description ?? '';
          
          // Social links
          socialLinks.value = List<String>.from(brand.value!.socialLinks);
        }
      } else {
        // Load creator data
        creator.value = _authService.currentCreator.value;
        
        if (creator.value != null) {
          // Populate form fields
          fullNameController.text = creator.value!.fullName;
          contentTypeController.text = creator.value!.contentType;
          mainCategoryController.text = creator.value!.mainCategory;
          emailController.text = creator.value!.email;
          phoneController.text = creator.value!.phone;
          countryController.text = creator.value!.country;
          bioController.text = creator.value!.bio ?? '';
          
          // Social links
          socialLinks.value = List<String>.from(creator.value!.socialLinks);
          
          // Portfolio
          portfolioUrls.value = List<String>.from(creator.value!.portfolioUrls);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load profile data: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        imageFile.value = File(image.path);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: ${e.toString()}');
    }
  }
  
  Future<void> pickPortfolioImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();
      
      if (images.isNotEmpty) {
        for (var image in images) {
          portfolioFiles.add(File(image.path));
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick images: ${e.toString()}');
    }
  }
  
  void addSocialLink() {
    socialLinks.add('');
  }
  
  void updateSocialLink(int index, String value) {
    if (index < socialLinks.length) {
      socialLinks[index] = value;
    }
  }
  
  void removeSocialLink(int index) {
    if (index < socialLinks.length) {
      socialLinks.removeAt(index);
    }
  }
  
  void removePortfolioUrl(int index) {
    if (index < portfolioUrls.length) {
      portfolioUrls.removeAt(index);
    }
  }
  
  void removePortfolioFile(int index) {
    if (index < portfolioFiles.length) {
      portfolioFiles.removeAt(index);
    }
  }
  
  Future<void> saveChanges() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    
    try {
      isSaving.value = true;
      
      // Upload profile image if changed
      String? imageUrl;
      if (imageFile.value != null) {
        if (userType.value == AppConstants.userTypeBrand) {
          imageUrl = await _storageService.uploadBrandLogo(
            imageFile.value!,
            brand.value!.id,
          );
        } else {
          imageUrl = await _storageService.uploadProfileImage(
            imageFile.value!,
            creator.value!.id,
          );
        }
      }
      
      // Upload new portfolio images
      List<String> newPortfolioUrls = [];
      for (var file in portfolioFiles) {
        final url = await _storageService.uploadFile(
          file,
          'portfolio/${creator.value!.id}',
        );
        
        if (url != null) {
          newPortfolioUrls.add(url);
        }
      }
      
      // Combine with existing portfolio URLs
      final allPortfolioUrls = [...portfolioUrls, ...newPortfolioUrls];
      
      if (userType.value == AppConstants.userTypeBrand) {
        // Update brand
        final updatedBrand = brand.value!.copyWith(
          companyName: companyNameController.text,
          businessCategory: businessCategoryController.text,
          email: emailController.text,
          phone: phoneController.text,
          country: countryController.text,
          websiteUrl: websiteController.text.isNotEmpty ? websiteController.text : null,
          description: descriptionController.text.isNotEmpty ? descriptionController.text : null,
          logoUrl: imageUrl ?? brand.value!.logoUrl,
          socialLinks: socialLinks.where((link) => link.isNotEmpty).toList(),
          updatedAt: DateTime.now(),
        );
        
        await _firestoreService.updateBrand(updatedBrand);
        
        // Update user record
        final user = _authService.currentUser.value;
        if (user != null) {
          await _firestoreService.updateUser(
            user.copyWith(
              email: emailController.text,
              phone: phoneController.text,
              country: countryController.text,
              profileImage: imageUrl ?? user.profileImage,
              updatedAt: DateTime.now(),
            ),
          );
        }
        
        // Update local data
        _authService.currentBrand.value = updatedBrand;
      } else {
        // Update creator
        final updatedCreator = creator.value!.copyWith(
          fullName: fullNameController.text,
          contentType: contentTypeController.text,
          mainCategory: mainCategoryController.text,
          email: emailController.text,
          phone: phoneController.text,
          country: countryController.text,
          bio: bioController.text.isNotEmpty ? bioController.text : null,
          profileImage: imageUrl ?? creator.value!.profileImage,
          portfolioUrls: allPortfolioUrls,
          socialLinks: socialLinks.where((link) => link.isNotEmpty).toList(),
          updatedAt: DateTime.now(),
        );
        
        await _firestoreService.updateCreator(updatedCreator);
        
        // Update user record
        final user = _authService.currentUser.value;
        if (user != null) {
          await _firestoreService.updateUser(
            user.copyWith(
              email: emailController.text,
              phone: phoneController.text,
              country: countryController.text,
              profileImage: imageUrl ?? user.profileImage,
              updatedAt: DateTime.now(),
            ),
          );
        }
        
        // Update local data
        _authService.currentCreator.value = updatedCreator;
      }
      
      Get.back();
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: ${e.toString()}');
    } finally {
      isSaving.value = false;
    }
  }
}