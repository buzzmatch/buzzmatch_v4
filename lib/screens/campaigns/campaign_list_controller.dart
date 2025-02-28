// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../constants/app_constants.dart';
import '../../models/campaign_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../routes/app_pages.dart';

class CampaignListController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  
  // Text controller for search
  final TextEditingController searchController = TextEditingController();
  
  // Observable variables
  final RxBool isLoading = true.obs;
  final RxString userType = ''.obs;
  final RxList<CampaignModel> allCampaigns = <CampaignModel>[].obs;
  final RxList<CampaignModel> filteredCampaigns = <CampaignModel>[].obs;
  final RxList<String> activeFilters = <String>[].obs;
  
  // Content type filters for creators
  final RxList<String> contentTypeFilters = AppConstants.contentTypes.obs;
  
  // Status filters for brands
  final RxList<String> statusFilters = <String>[
    'Active',
    'Inactive',
    'Completed',
  ].obs;
  
  @override
  void onInit() {
    super.onInit();
    
    // Determine user type
    userType.value = _authService.currentUser.value?.userType ?? '';
    
    loadCampaigns();
    
    // Add listener to search controller
    searchController.addListener(filterCampaigns);
  }
  
  @override
  void onClose() {
    searchController.removeListener(filterCampaigns);
    searchController.dispose();
    super.onClose();
  }
  
  Future<void> loadCampaigns() async {
    try {
      isLoading.value = true;
      
      List<DocumentSnapshot> campaignDocs;
      
      if (userType.value == AppConstants.userTypeBrand) {
        // For brands, load their own campaigns
        final brandId = _authService.currentBrand.value?.id;
        if (brandId != null) {
          campaignDocs = await _firestoreService.getBrandCampaigns(brandId);
        } else {
          campaignDocs = [];
        }
      } else {
        // For creators, load active campaigns
        campaignDocs = await _firestoreService.getActiveCampaigns();
      }
      
      // Convert to campaign models
      final campaigns = campaignDocs
          .map((doc) => CampaignModel.fromFirestore(doc))
          .toList();
      
      // Sort by creation date (newest first)
      campaigns.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      allCampaigns.value = campaigns;
      
      // Apply any existing filters
      filterCampaigns();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load campaigns: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> refreshCampaigns() async {
    await loadCampaigns();
  }
  
  void filterCampaigns() {
    final searchTerm = searchController.text.toLowerCase();
    
    filteredCampaigns.value = allCampaigns.where((campaign) {
      // Apply search filter
      if (searchTerm.isNotEmpty) {
        final nameMatch = campaign.campaignName.toLowerCase().contains(searchTerm);
        final brandMatch = campaign.brandName.toLowerCase().contains(searchTerm);
        final productMatch = campaign.productName.toLowerCase().contains(searchTerm);
        
        if (!nameMatch && !brandMatch && !productMatch) {
          return false;
        }
      }
      
      // Apply active filters
      if (activeFilters.isNotEmpty) {
        // For content type filters
        if (activeFilters.any((filter) => AppConstants.contentTypes.contains(filter))) {
          final contentTypeFilters = activeFilters
              .where((filter) => AppConstants.contentTypes.contains(filter))
              .toList();
          
          if (contentTypeFilters.isNotEmpty) {
            final hasMatchingContentType = campaign.requiredContentTypes
                .any((type) => contentTypeFilters.contains(type));
            
            if (!hasMatchingContentType) {
              return false;
            }
          }
        }
        
        // For status filters
        if (activeFilters.contains('Active') && !campaign.isActive) {
          return false;
        }
        
        if (activeFilters.contains('Inactive') && campaign.isActive) {
          return false;
        }
      }
      
      return true;
    }).toList();
  }
  
  void showFilterOptions() {
    if (userType.value == AppConstants.userTypeBrand) {
      _showBrandFilterOptions();
    } else {
      _showCreatorFilterOptions();
    }
  }
  
  void _showBrandFilterOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Campaigns',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Status',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: statusFilters.map((status) {
                final isActive = activeFilters.contains(status);
                return FilterChip(
                  selected: isActive,
                  label: Text(status),
                  onSelected: (selected) {
                    if (selected) {
                      activeFilters.add(status);
                    } else {
                      activeFilters.remove(status);
                    }
                    filterCampaigns();
                  },
                  selectedColor: Colors.blue.withOpacity(0.2),
                  checkmarkColor: Colors.blue,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    activeFilters.clear();
                    filterCampaigns();
                    Get.back();
                  },
                  child: const Text('Clear All'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: const Text('Apply'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _showCreatorFilterOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Campaigns',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Content Type',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: contentTypeFilters.map((type) {
                final isActive = activeFilters.contains(type);
                return FilterChip(
                  selected: isActive,
                  label: Text(type),
                  onSelected: (selected) {
                    if (selected) {
                      activeFilters.add(type);
                    } else {
                      activeFilters.remove(type);
                    }
                    filterCampaigns();
                  },
                  selectedColor: Colors.blue.withOpacity(0.2),
                  checkmarkColor: Colors.blue,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    activeFilters.clear();
                    filterCampaigns();
                    Get.back();
                  },
                  child: const Text('Clear All'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: const Text('Apply'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void removeFilter(String filter) {
    activeFilters.remove(filter);
    filterCampaigns();
  }
  
  void navigateToCreateCampaign() {
    Get.toNamed('/campaign-create');
  }
  
  void navigateToCampaignDetails(String campaignId) {
    Get.toNamed('/campaign-detail', arguments: {'campaignId': campaignId});
  }
  Future<void> applyCampaign(String campaignId) async {
    try {
      final creatorId = _authService.currentCreator.value?.id;
      if (creatorId == null) {
        Get.snackbar('Error', 'Creator profile not found');
        return;
      }
      
      // Get the campaign
      final campaignDoc = await _firestoreService.getCampaign(campaignId);
      if (campaignDoc == null) {
        Get.snackbar('Error', 'Campaign not found');
        return;
      }
      
      final campaign = CampaignModel.fromFirestore(campaignDoc);
      
      // Check if already applied
      if (campaign.appliedCreators.contains(creatorId)) {
        Get.snackbar('Info', 'You have already applied to this campaign');
        return;
      }
      
      // Add creator to applied creators
      final updatedAppliedCreators = [...campaign.appliedCreators, creatorId];
      
      // Update campaign
      await _firestoreService.updateCampaign(
        campaign.copyWith(
          appliedCreators: updatedAppliedCreators,
        ),
      );
      
      Get.snackbar(
        'Success',
        'You have successfully applied for this campaign',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      // Refresh campaigns
      await refreshCampaigns();
    } catch (e) {
      Get.snackbar('Error', 'Failed to apply: ${e.toString()}');
    }
  }
}