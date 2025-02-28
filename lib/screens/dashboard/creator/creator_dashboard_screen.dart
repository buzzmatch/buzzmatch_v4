import 'package:buzz_match/screens/dashboard/brand/widgets/available_campaign_card.dart';
import 'package:buzz_match/screens/dashboard/brand/widgets/creator_collaboration_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_styles.dart';
import '../../../widgets/common/custom_button.dart';
import 'creator_dashboard_controller.dart';
import 'widgets/stats_card.dart';
// Removed the imports for non-existent files

class CreatorDashboardScreen extends StatelessWidget {
  const CreatorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreatorDashboardController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.refreshData(),
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Creator header
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.primary,
                        backgroundImage: controller.creator.value?.profileImage != null
                            ? NetworkImage(controller.creator.value!.profileImage!)
                            : null,
                        child: controller.creator.value?.profileImage == null
                            ? Text(
                                controller.creator.value?.fullName.substring(0, 1) ?? 'C',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.creator.value?.fullName ?? 'Creator Name',
                              style: AppStyles.heading2,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              controller.creator.value?.mainCategory ?? 'Category',
                              style: AppStyles.body2.copyWith(color: AppColors.grey),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => controller.navigateToNotifications(),
                        icon: const Icon(Icons.notifications_outlined),
                        color: AppColors.dark,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  // Stats cards
                  StatsCard(
                    collaborationsCount: controller.collaborationsCount.value,
                    completedCollaborationsCount: controller.completedCollaborationsCount.value,
                    walletBalance: controller.walletBalance.value,
                    pendingBalance: controller.pendingBalance.value,
                  ),

                  const SizedBox(height: 24),

                  // Campaigns matching your profile
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Campaigns For You', style: AppStyles.heading3),
                      TextButton(
                        onPressed: () => controller.navigateToAllCampaigns(),
                        child: Text(
                          'View All',
                          style: AppStyles.body2.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Matching campaigns list
                  if (controller.matchingCampaigns.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          'No campaigns matching your profile',
                          style: TextStyle(color: AppColors.grey),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      height: 220,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.matchingCampaigns.length,
                        itemBuilder: (context, index) {
                          final campaign = controller.matchingCampaigns[index];
                          return AvailableCampaignCard(
                            campaign: campaign,
                            onTap: () => controller.navigateToCampaignDetails(campaign.id),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Active collaborations
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Active Collaborations', style: AppStyles.heading3),
                      TextButton(
                        onPressed: () => controller.navigateToCollaborations(),
                        child: Text(
                          'View All',
                          style: AppStyles.body2.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Active collaborations list
                  if (controller.activeCollaborations.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          'No active collaborations',
                          style: TextStyle(color: AppColors.grey),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.activeCollaborations.length > 3
                          ? 3
                          : controller.activeCollaborations.length,
                      itemBuilder: (context, index) {
                        final collaboration = controller.activeCollaborations[index];
                        return CreatorCollaborationCard(
                          collaboration: collaboration,
                          onTap: () => controller.navigateToCollaborationDetails(
                            collaboration.id,
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 24),
                  
                  // Portfolio section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Your Portfolio', style: AppStyles.heading3),
                      TextButton(
                        onPressed: () => controller.navigateToEditProfile(),
                        child: Text(
                          'Manage',
                          style: AppStyles.body2.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Portfolio preview
                  if (controller.creator.value?.portfolioUrls.isEmpty ?? true)
                    CustomButton(
                      label: 'Add Portfolio Items',
                      onPressed: () => controller.navigateToEditProfile(),
                      icon: Icons.add_photo_alternate,
                    )
                  else
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.creator.value!.portfolioUrls.length > 5
                            ? 5
                            : controller.creator.value!.portfolioUrls.length,
                        itemBuilder: (context, index) {
                          final imageUrl = controller.creator.value!.portfolioUrls[index];
                          return Container(
                            width: 120,
                            height: 120,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: NetworkImage(imageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        }),
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.selectedIndex.value,
          onTap: controller.changeTab,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.campaign_outlined),
              activeIcon: Icon(Icons.campaign),
              label: 'Campaigns',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.handshake_outlined),
              activeIcon: Icon(Icons.handshake),
              label: 'Collaborations',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_outlined),
              activeIcon: Icon(Icons.chat),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}