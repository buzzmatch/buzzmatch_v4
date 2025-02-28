import 'package:get/get.dart';

import '../../../models/brand_model.dart';
import '../../../models/campaign_model.dart';
import '../../../models/collaboration_model.dart';
import '../../../models/wallet_models.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';
import '../../../routes/app_pages.dart';

class BrandDashboardController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  
  // Observable variables
  final RxBool isLoading = true.obs;
  final RxInt selectedIndex = 0.obs;
  
  // Brand data
  final Rx<BrandModel?> brand = Rx<BrandModel?>(null);
  
  // Dashboard data
  final RxInt campaignsCount = 0.obs;
  final RxInt collaborationsCount = 0.obs;
  final RxDouble walletBalance = 0.0.obs;
  
  // Lists
  final RxList<CampaignModel> activeCampaigns = <CampaignModel>[].obs;
  final RxList<CollaborationModel> recentCollaborations = <CollaborationModel>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    loadData();
  }
  
  Future<void> loadData() async {
    try {
      isLoading.value = true;
      
      // Get brand data
      brand.value = _authService.currentBrand.value;
      
      if (brand.value != null) {
        // Load campaigns
        final campaignDocs = await _firestoreService.getBrandCampaigns(brand.value!.id);
        final campaigns = campaignDocs
            .map((doc) => CampaignModel.fromFirestore(doc))
            .toList();
        
        campaignsCount.value = campaigns.length;
        
        // Filter active campaigns
        activeCampaigns.value = campaigns
            .where((campaign) => campaign.isActive)
            .toList();
        
        // Load collaborations
        final collaborationDocs = await _firestoreService.getBrandCollaborations(brand.value!.id);
        final collaborations = collaborationDocs
            .map((doc) => CollaborationModel.fromFirestore(doc))
            .toList();
        
        collaborationsCount.value = collaborations.length;
        
        // Recent collaborations (sorted by updatedAt)
        collaborations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        recentCollaborations.value = collaborations.take(5).toList();
        
        // Load wallet data
        final walletDoc = await _firestoreService.getWallet(brand.value!.id);
        if (walletDoc != null) {
          final wallet = WalletModel.fromFirestore(walletDoc);
          walletBalance.value = wallet.balance;
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
  void navigateToCreateCampaign() {
    Get.toNamed('/campaign-create');
  }
  void navigateToCampaigns() {
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
  
  void navigateToNotifications() {
    // TODO: Implement notifications screen
    Get.snackbar('Coming Soon', 'Notifications feature coming soon!');
  }
}