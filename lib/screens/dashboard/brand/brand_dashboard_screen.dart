// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_styles.dart';
import '../../../widgets/common/custom_button.dart';
import 'brand_dashboard_controller.dart';
import 'widgets/brand_campaign_card.dart';
import 'widgets/brand_stats_card.dart';

class BrandDashboardScreen extends StatelessWidget {
  const BrandDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
final controller = Get.put(BrandDashboardController(), permanent: true);

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
                  // Brand header
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.primary,
                        backgroundImage: controller.brand.value?.logoUrl != null
                            ? NetworkImage(controller.brand.value!.logoUrl!)
                            : null,
                        child: controller.brand.value?.logoUrl == null
                            ? Text(
                                controller.brand.value?.companyName.substring(0, 1) ?? 'B',
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
                              controller.brand.value?.companyName ?? 'Brand Name',
                              style: AppStyles.heading2,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              controller.brand.value?.businessCategory ?? 'Category',
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
                  BrandStatsCard(
                    campaignsCount: controller.campaignsCount.value,
                    collaborationsCount: controller.collaborationsCount.value,
                    walletBalance: controller.walletBalance.value,
                  ),

                  const SizedBox(height: 24),

                  // Create campaign button
                  CustomButton(
                    label: 'Create New Campaign',
                    onPressed: () => controller.navigateToCreateCampaign(),
                    icon: Icons.add,
                    color: AppColors.secondary,
                  ),

                  const SizedBox(height: 24),

                  // Active campaigns
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Active Campaigns', style: AppStyles.heading3),
                      TextButton(
                        onPressed: () => controller.navigateToCampaigns(),
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

                  // Campaigns list
                  if (controller.activeCampaigns.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          'No active campaigns',
                          style: TextStyle(color: AppColors.grey),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.activeCampaigns.length > 3
                          ? 3
                          : controller.activeCampaigns.length,
                      itemBuilder: (context, index) {
                        final campaign = controller.activeCampaigns[index];
                        return BrandCampaignCard(
                          campaign: campaign,
                          onTap: () => controller.navigateToCampaignDetails(campaign.id),
                        );
                      },
                    ),

                  const SizedBox(height: 24),

                  // Recent collaborations
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Recent Collaborations', style: AppStyles.heading3),
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

                  // Collaborations list
                  if (controller.recentCollaborations.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          'No recent collaborations',
                          style: TextStyle(color: AppColors.grey),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.recentCollaborations.length > 3
                          ? 3
                          : controller.recentCollaborations.length,
                      itemBuilder: (context, index) {
                        final collaboration = controller.recentCollaborations[index];
                        return GestureDetector(
                          onTap: () => controller.navigateToCollaborationDetails(
                            collaboration.id,
                          ),
                          child: BrandCollaborationCard(),
                        );
                      },
                    ),
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

class BrandCollaborationCard extends StatelessWidget {
  const BrandCollaborationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Collaboration Title',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Collaboration details go here...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
