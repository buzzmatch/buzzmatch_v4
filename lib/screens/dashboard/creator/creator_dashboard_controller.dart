import 'package:get/get.dart';

import '../../../models/creator_model.dart';
import '../../../models/campaign_model.dart';
import '../../../models/collaboration_model.dart';
import '../../../models/wallet_models.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';
import '../../../constants/app_constants.dart';
import '../../../routes/app_pages.dart';

class CreatorDashboardController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  
  // Observable variables
  final RxBool isLoading = true.obs;
  final RxInt selectedIndex = 0.obs;
  
  // Creator data
  final Rx<CreatorModel?> creator = Rx<CreatorModel?>(null);
  
  // Dashboard data
  final RxInt collaborationsCount = 0.obs;
  final RxInt completedCollaborationsCount = 0.obs;
  final RxDouble walletBalance = 0.0.obs;
  final RxDouble pendingBalance = 0.0.obs;
  
  // Lists
  final RxList<CampaignModel> matchingCampaigns = <CampaignModel>[].obs;
  final RxList<CollaborationModel> activeCollaborations = <CollaborationModel>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    loadData();
  }
  
  Future<void> loadData() async {
    try {
      isLoading.value = true;
      
      // Get creator data
      creator.value = _authService.currentCreator.value;
      
      if (creator.value != null) {
        // Load matching campaigns
        if (creator.value!.contentType.isNotEmpty) {
          final campaignDocs = await _firestoreService.getCampaignsByContentType(
            creator.value!.contentType,
          );
          
          final campaigns = campaignDocs
              .map((doc) => CampaignModel.fromFirestore(doc))
              .toList();
          
          // Filter out campaigns where creator already applied or is selected
          matchingCampaigns.value = campaigns.where((campaign) => 
            !campaign.appliedCreators.contains(creator.value!.id) &&
            !campaign.selectedCreators.contains(creator.value!.id)
          ).toList();
        }
        
        // Load collaborations
        final collaborationDocs = await _firestoreService.getCreatorCollaborations(
          creator.value!.id,
        );
        
        final collaborations = collaborationDocs
            .map((doc) => CollaborationModel.fromFirestore(doc))
            .toList();
        
        collaborationsCount.value = collaborations.length;
        
        // Count completed collaborations
        completedCollaborationsCount.value = collaborations
            .where((c) => c.status == AppConstants.statusCompleted)
            .length;
        
        // Filter active collaborations (not completed)
        activeCollaborations.value = collaborations
            .where((c) => c.status != AppConstants.statusCompleted)
            .toList();
        
        // Sort by most recent updates
        activeCollaborations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        
        // Load wallet data
        final walletDoc = await _firestoreService.getWallet(creator.value!.id);
        if (walletDoc != null) {
          final wallet = WalletModel.fromFirestore(walletDoc);
          walletBalance.value = wallet.balance;
          pendingBalance.value = wallet.pendingBalance;
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load dashboard data: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> refreshData() async {
    await loadData();
  }
  
  void changeTab(int index) {
    selectedIndex.value = index;
    
    switch (index) {
      case 0:
        // Already on dashboard
        break;
      case 1:
        Get.toNamed('/campaign-list');
        break;
      case 2:
        Get.toNamed('/collaboration-list');
        break;
      case 3:
        Get.toNamed(Routes.CHAT_LIST);
        break;
      case 4:
        Get.toNamed('/profile');
        break;
    }
  }
  void navigateToAllCampaigns() {
    Get.toNamed('/campaign-list');
  }
  
  void navigateToCollaborations() {
    Get.toNamed('/collaboration-list');
  }
  
  void navigateToCampaignDetails(String campaignId) {
    Get.toNamed(
      '/campaign-detail',
      arguments: {'campaignId': campaignId},
    );
  }
  void navigateToCollaborationDetails(String collaborationId) {
    Get.toNamed(
      Routes.COLLABORATION_DETAIL,
      arguments: {'collaborationId': collaborationId},
    );
  }
  void navigateToEditProfile() {
    Get.toNamed('/profile-edit');
  }
  
  void navigateToNotifications() {
    // TODO: Implement notifications screen
    Get.snackbar('Coming Soon', 'Notifications feature coming soon!');
  }
}