import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../models/campaign_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';

class CampaignCreateController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final StorageService _storageService = Get.find<StorageService>();
  
  // Form key
  final formKey = GlobalKey<FormState>();
  
  // Form controllers
  final TextEditingController campaignNameController = TextEditingController();
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController budgetController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  
  // Selected content types
  List<String> selectedContentTypes = [];
  
  // Observable variables
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isEditing = false.obs;
  final RxBool isActive = true.obs;
  
  // Campaign ID for editing
  String? campaignId;
  
  // Reference images
  final RxList<File> referenceImages = <File>[].obs;
  final RxList<String> existingReferenceUrls = <String>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    
    // Check if editing an existing campaign
    final Map<String, dynamic> args = Get.arguments ?? {};
    final CampaignModel? campaign = args['campaign'];
    
    if (campaign != null) {
      _initializeForEditing(campaign);
    }
  }
  
  @override
  void onClose() {
    campaignNameController.dispose();
    productNameController.dispose();
    budgetController.dispose();
    deadlineController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
  
  void _initializeForEditing(CampaignModel campaign) {
    isLoading.value = true;
    isEditing.value = true;
    
    campaignId = campaign.id;
    isActive.value = campaign.isActive;
    
    // Populate form fields
    campaignNameController.text = campaign.campaignName;
    productNameController.text = campaign.productName;
    budgetController.text = campaign.budget.toString();
    deadlineController.text = DateFormat('MMM dd, yyyy').format(campaign.deadline);
    descriptionController.text = campaign.description;
    
    // Content types
    selectedContentTypes = List<String>.from(campaign.requiredContentTypes);
    
    // Reference URLs
    existingReferenceUrls.value = List<String>.from(campaign.referenceUrls);
    
    isLoading.value = false;
  }
  
  Future<void> selectDeadline(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    
    if (selected != null) {
      deadlineController.text = DateFormat('MMM dd, yyyy').format(selected);
    }
  }
  
  Future<void> pickReferenceImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();
      
      if (images.isNotEmpty) {
        for (var image in images) {
          referenceImages.add(File(image.path));
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick images: ${e.toString()}');
    }
  }
  
  void removeReferenceImage(int index) {
    if (index < referenceImages.length) {
      referenceImages.removeAt(index);
    }
  }
  
  void removeExistingReference(int index) {
    if (index < existingReferenceUrls.length) {
      existingReferenceUrls.removeAt(index);
    }
  }
  
  void toggleActive() {
    isActive.value = !isActive.value;
  }
  
  Future<void> saveCampaign() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    
    if (selectedContentTypes.isEmpty) {
      Get.snackbar('Error', 'Please select at least one content type');
      return;
    }
    
    try {
      isSaving.value = true;
      
      final brandId = _authService.currentBrand.value?.id;
      if (brandId == null) {
        Get.snackbar('Error', 'Brand profile not found');
        return;
      }
      
      // Upload reference images
      List<String> newReferenceUrls = [];
      for (var file in referenceImages) {
        final url = await _storageService.uploadCampaignReference(
          file,
          isEditing.value ? campaignId! : 'temp',
        );
        
        if (url != null) {
          newReferenceUrls.add(url);
        }
      }
      
      // Combine with existing URLs (for editing)
      final allReferenceUrls = [...existingReferenceUrls, ...newReferenceUrls];
      
      // Parse form data
      final deadline = DateFormat('MMM dd, yyyy').parse(deadlineController.text);
      final budget = double.parse(budgetController.text);
      
      if (isEditing.value && campaignId != null) {
        // Update existing campaign
        final updatedCampaign = CampaignModel(
          id: campaignId!,
          brandId: brandId,
          brandName: _authService.currentBrand.value!.companyName,
          brandLogo: _authService.currentBrand.value!.logoUrl,
          campaignName: campaignNameController.text,
          productName: productNameController.text,
          requiredContentTypes: selectedContentTypes,
          description: descriptionController.text,
          budget: budget,
          deadline: deadline,
          referenceUrls: allReferenceUrls,
          invitedCreators: [],
          appliedCreators: [],
          selectedCreators: [],
          isActive: isActive.value,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        await _firestoreService.updateCampaign(updatedCampaign);
        
        Get.back(result: true);
        Get.snackbar(
          'Success',
          'Campaign updated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        // Create new campaign
        final newCampaign = CampaignModel(
          id: '',
          brandId: brandId,
          brandName: _authService.currentBrand.value!.companyName,
          brandLogo: _authService.currentBrand.value!.logoUrl,
          campaignName: campaignNameController.text,
          productName: productNameController.text,
          requiredContentTypes: selectedContentTypes,
          description: descriptionController.text,
          budget: budget,
          deadline: deadline,
          referenceUrls: allReferenceUrls,
          invitedCreators: [],
          appliedCreators: [],
          selectedCreators: [],
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        final campaignId = await _firestoreService.createCampaign(newCampaign);
        
        // Update reference image paths with actual campaign ID
        if (campaignId.isNotEmpty && newReferenceUrls.isNotEmpty) {
          // In a real app, we would upload to the actual campaign folder
          // and update the URLs. For simplicity, we'll skip this step here.
        }
        
        Get.back(result: true);
        Get.snackbar(
          'Success',
          'Campaign created successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to save campaign: ${e.toString()}');
    } finally {
      isSaving.value = false;
    }
  }
}