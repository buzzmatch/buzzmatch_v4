import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_styles.dart';
import '../../models/campaign_model.dart';
import '../../widgets/common/custom_button.dart';
import 'campaign_list_controller.dart';
import 'campaign_list_item.dart';

class CampaignListScreen extends StatelessWidget {
  const CampaignListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CampaignListController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Campaigns'),
        actions: [
          // Filter button
          IconButton(
            onPressed: () => controller.showFilterOptions(),
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: controller.searchController,
              onChanged: (value) => controller.filterCampaigns(),
              decoration: InputDecoration(
                hintText: 'Search campaigns...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          
          // Filter chips
          Obx(() {
            if (controller.activeFilters.isEmpty) {
              return const SizedBox.shrink();
            }
            
            return Container(
              height: 40,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.activeFilters.length,
                itemBuilder: (context, index) {
                  final filter = controller.activeFilters[index];
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: Chip(
                      label: Text(filter),
                      deleteIcon: const Icon(
                        Icons.close,
                        size: 16,
                      ),
                      onDeleted: () => controller.removeFilter(filter),
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      labelStyle: AppStyles.caption.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  );
                },
              ),
            );
          }),
          
          // Campaign list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                );
              }
              
              if (controller.filteredCampaigns.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.campaign_outlined,
                        size: 64,
                        color: AppColors.grey.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No campaigns found',
                        style: AppStyles.heading3.copyWith(
                          color: AppColors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (controller.userType.value == 'brand') ...[
                        const SizedBox(height: 16),
                        CustomButton(
                          label: 'Create Campaign',
                          onPressed: () => controller.navigateToCreateCampaign(),
                          icon: Icons.add,
                          fullWidth: false,
                        ),
                      ],
                    ],
                  ),
                );
              }
              
              return RefreshIndicator(
                onRefresh: () => controller.refreshCampaigns(),
                color: AppColors.primary,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.filteredCampaigns.length,
                  itemBuilder: (context, index) {
                    final campaign = controller.filteredCampaigns[index];
                    return CampaignListItem(
                      campaign: campaign,
                      userType: controller.userType.value,
                      onTap: () => controller.navigateToCampaignDetails(campaign.id),
                      onApply: controller.userType.value == 'creator'
                          ? () => controller.applyCampaign(campaign.id)
                          : null,
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: Obx(() {
        if (controller.userType.value == 'brand') {
          return FloatingActionButton(
            onPressed: () => controller.navigateToCreateCampaign(),
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add),
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }
}