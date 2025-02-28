import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' show Text;
import 'package:get/get.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

import '../../routes/app_pages.dart';

import '../../models/chat_models.dart';

import '../../models/campaign_model.dart';
import '../../models/creator_model.dart';
import '../../models/collaboration_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../constants/app_constants.dart';

class CampaignDetailController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  
  // Observable variables
  final RxBool isLoading = true.obs;
  final Rx<CampaignModel?> campaign = Rx<CampaignModel?>(null);
  final RxString userType = ''.obs;
  final RxInt selectedTab = 0.obs;
  final RxBool hasApplied = false.obs;
  
  // Creator cache to avoid repeated fetches
  final Map<String, CreatorModel> _creatorCache = {};
  
  @override
  void onInit() {
    super.onInit();
    
    // Determine user type
    userType.value = _authService.currentUser.value?.userType ?? '';
    
    // Get campaign ID from arguments
    final Map<String, dynamic> args = Get.arguments ?? {};
    final String campaignId = args['campaignId'] ?? '';
    
    if (campaignId.isNotEmpty) {
      loadCampaign(campaignId);
    } else {
      isLoading.value = false;
    }
  }
  
  Future<void> loadCampaign(String campaignId) async {
    try {
      isLoading.value = true;
      
      final campaignDoc = await _firestoreService.getCampaign(campaignId);
      if (campaignDoc != null) {
        campaign.value = CampaignModel.fromFirestore(campaignDoc);
        
        // For creators, check if they have applied
        if (userType.value == AppConstants.userTypeCreator) {
          final creatorId = _authService.currentCreator.value?.id;
          if (creatorId != null) {
            hasApplied.value = campaign.value!.appliedCreators.contains(creatorId);
          }
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load campaign: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
  
  void changeTab(int index) {
    selectedTab.value = index;
  }
  
  Future<CreatorModel?> getCreatorDetails(String creatorId) async {
    // Check cache first
    if (_creatorCache.containsKey(creatorId)) {
      return _creatorCache[creatorId];
    }
    
    try {
      final creatorDoc = await _firestoreService.getCreator(creatorId);
      if (creatorDoc != null) {
        final creator = CreatorModel.fromFirestore(creatorDoc);
        _creatorCache[creatorId] = creator;
        return creator;
      }
    } catch (e) {
      print('Error fetching creator details: $e');
    }
    
    return null;
  }
  
  Future<void> navigateToEditCampaign() async {
    if (campaign.value == null) return;
    final result = await Get.toNamed(
      '/campaign-create',
      arguments: {'campaign': campaign.value},
    );
    
    if (result == true) {
      await loadCampaign(campaign.value!.id);
    }
  }
  
  Future<void> toggleCampaignStatus() async {
    if (campaign.value == null) return;
    
    try {
      final updatedCampaign = campaign.value!.copyWith(
        isActive: !campaign.value!.isActive,
      );
      
      await _firestoreService.updateCampaign(updatedCampaign);
      
      campaign.value = updatedCampaign;
      
      Get.snackbar(
        'Success',
        'Campaign ${updatedCampaign.isActive ? 'activated' : 'paused'} successfully',
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to update campaign: ${e.toString()}');
    }
  }
  
  void showDeleteConfirmation() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Campaign?'),
        content: const Text(
          'This action cannot be undone. All associated collaborations will remain, but the campaign will no longer be visible to creators.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              deleteCampaign();
            },
            child: const Text('Delete'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> deleteCampaign() async {
    if (campaign.value == null) return;
    
    try {
      isLoading.value = true;
      
      // Update campaign status to inactive instead of actually deleting it
      final updatedCampaign = campaign.value!.copyWith(
        isActive: false,
      );
      
      await _firestoreService.updateCampaign(updatedCampaign);
      
      Get.back();
      Get.snackbar(
        'Success',
        'Campaign deleted successfully',
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete campaign: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> applyCampaign() async {
    if (campaign.value == null) return;
    
    try {
      final creatorId = _authService.currentCreator.value?.id;
      if (creatorId == null) {
        Get.snackbar('Error', 'Creator profile not found');
        return;
      }
      
      // Check if already applied
      if (campaign.value!.appliedCreators.contains(creatorId)) {
        Get.snackbar('Info', 'You have already applied to this campaign');
        return;
      }
      
      // Add creator to applied creators
      final updatedAppliedCreators = [...campaign.value!.appliedCreators, creatorId];
      
      // Update campaign
      final updatedCampaign = campaign.value!.copyWith(
        appliedCreators: updatedAppliedCreators,
      );
      
      await _firestoreService.updateCampaign(updatedCampaign);
      
      campaign.value = updatedCampaign;
      hasApplied.value = true;
      
      Get.snackbar(
        'Success',
        'You have successfully applied for this campaign',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to apply: ${e.toString()}');
    }
  }
  
  Future<void> selectCreator(String creatorId) async {
    if (campaign.value == null) return;
    
    try {
      // Add creator to selected creators
      final updatedSelectedCreators = [...campaign.value!.selectedCreators, creatorId];
      
      // Remove from applied creators
      final updatedAppliedCreators = [...campaign.value!.appliedCreators]
        ..remove(creatorId);
      
      // Update campaign
      final updatedCampaign = campaign.value!.copyWith(
        selectedCreators: updatedSelectedCreators,
        appliedCreators: updatedAppliedCreators,
      );
      
      await _firestoreService.updateCampaign(updatedCampaign);
      
      campaign.value = updatedCampaign;
      
      Get.snackbar(
        'Success',
        'Creator selected successfully',
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to select creator: ${e.toString()}');
    }
  }
  
  Future<void> startCollaboration(String creatorId) async {
    if (campaign.value == null) return;
    
    try {
      // Create a new collaboration
      final collaboration = CollaborationModel(
        id: '',
        campaignId: campaign.value!.id,
        brandId: campaign.value!.brandId,
        creatorId: creatorId,
        status: AppConstants.statusMatched,
        budget: campaign.value!.budget,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final collaborationId = await _firestoreService.createCollaboration(collaboration);
      
      // Create a chat for the collaboration
      await _firestoreService.createChat(ChatModel(
        id: '',
        campaignId: campaign.value!.id,
        collaborationId: collaborationId,
        brandId: campaign.value!.brandId,
        creatorId: creatorId,
        lastMessageTime: DateTime.now(),
        lastMessage: 'Collaboration started',
        lastSenderId: campaign.value!.brandId,
        unreadCount: {
          campaign.value!.brandId: 0,
          creatorId: 1,
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      
      Get.snackbar(
        'Success',
        'Collaboration started successfully',
      );
      
      // Navigate to collaboration details
      Get.toNamed(
        Routes.COLLABORATION_DETAIL,
        arguments: {'collaborationId': collaborationId},
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to start collaboration: ${e.toString()}');
    }
  }
  
  void viewCreatorProfile(String creatorId) {
    // TODO: Navigate to creator profile
    Get.snackbar('Coming Soon', 'Creator profile view coming soon!');
  }
  
  void navigateToInviteCreators() {
    // TODO: Navigate to invite creators
    Get.snackbar('Coming Soon', 'Creator invitation coming soon!');
  }
}