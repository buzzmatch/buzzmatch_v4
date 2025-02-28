import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_styles.dart';
import '../../constants/app_constants.dart';
import '../../widgets/common/custom_button.dart';
import 'campaign_detail_controller.dart';
import 'widgets/creator_list_item.dart';

class CampaignDetailScreen extends StatelessWidget {
  const CampaignDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CampaignDetailController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          );
        }

        if (controller.campaign.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Campaign not found',
                  style: AppStyles.heading3,
                ),
                const SizedBox(height: 24),
                CustomButton(
                  label: 'Go Back',
                  onPressed: () => Get.back(),
                  fullWidth: false,
                ),
              ],
            ),
          );
        }

        final campaign = controller.campaign.value!;
        final bool isBrand = controller.userType.value == AppConstants.userTypeBrand;
        final bool isDeadlinePassed = campaign.deadline.isBefore(DateTime.now());

        return CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  campaign.campaignName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 3.0,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ],
                  ),
                ),
                background: campaign.referenceUrls.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: campaign.referenceUrls.first,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.primary.withOpacity(0.3),
                          child: const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.primary,
                          child: Center(
                            child: Text(
                              campaign.campaignName.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 56,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(
                        color: AppColors.primary,
                        child: Center(
                          child: Text(
                            campaign.campaignName.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 56,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
              ),
              actions: [
                if (isBrand)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        controller.navigateToEditCampaign();
                      } else if (value == 'delete') {
                        controller.showDeleteConfirmation();
                      } else if (value == 'toggle') {
                        controller.toggleCampaignStatus();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Edit Campaign'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'toggle',
                        child: Row(
                          children: [
                            Icon(
                              campaign.isActive ? Icons.pause : Icons.play_arrow,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(campaign.isActive
                                ? 'Pause Campaign'
                                : 'Activate Campaign'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete Campaign',
                                style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            // Campaign details
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand info
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.primary,
                          backgroundImage: campaign.brandLogo != null
                              ? NetworkImage(campaign.brandLogo!)
                              : null,
                          child: campaign.brandLogo == null
                              ? Text(
                                  campaign.brandName.substring(0, 1),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                campaign.brandName,
                                style: AppStyles.heading3,
                              ),
                              Text(
                                'Posted on ${DateFormat('MMM dd, yyyy').format(campaign.createdAt)}',
                                style: AppStyles.caption.copyWith(
                                  color: AppColors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: campaign.isActive
                                ? AppColors.success.withOpacity(0.1)
                                : AppColors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            campaign.isActive ? 'Active' : 'Inactive',
                            style: AppStyles.caption.copyWith(
                              color: campaign.isActive
                                  ? AppColors.success
                                  : AppColors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Campaign info cards
                    Row(
                      children: [
                        _buildInfoCard(
                          context,
                          'Budget',
                          '${AppConstants.currency} ${campaign.budget.toStringAsFixed(0)}',
                          Icons.attach_money,
                        ),
                        const SizedBox(width: 16),
                        _buildInfoCard(
                          context,
                          'Deadline',
                          DateFormat('MMM dd, yyyy').format(campaign.deadline),
                          Icons.calendar_today,
                          isWarning: isDeadlinePassed,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Product info
                    const Text(
                      'Product / Event',
                      style: AppStyles.heading3,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      campaign.productName,
                      style: AppStyles.body1,
                    ),

                    const SizedBox(height: 16),

                    // Content types
                    const Text(
                      'Required Content',
                      style: AppStyles.heading3,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: campaign.requiredContentTypes.map((type) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            type,
                            style: AppStyles.body2.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // Description
                    const Text(
                      'Description',
                      style: AppStyles.heading3,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      campaign.description,
                      style: AppStyles.body1,
                    ),

                    const SizedBox(height: 24),

                    // Reference materials
                    if (campaign.referenceUrls.isNotEmpty) ...[
                      const Text(
                        'Reference Materials',
                        style: AppStyles.heading3,
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: campaign.referenceUrls.length,
                          itemBuilder: (context, index) {
                            final url = campaign.referenceUrls[index];
                            return Container(
                              width: 120,
                              height: 120,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: url,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          AppColors.primary),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey.shade400,
                                    size: 32,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Creators section (for brand)
                    if (isBrand) ...[
                      // Tabs for creators
                      Obx(() => Row(
                        children: [
                          _buildCreatorTab(
                            'Selected',
                            controller.selectedTab.value == 0,
                            () => controller.changeTab(0),
                            campaign.selectedCreators.length,
                          ),
                          _buildCreatorTab(
                            'Applied',
                            controller.selectedTab.value == 1,
                            () => controller.changeTab(1),
                            campaign.appliedCreators.length,
                          ),
                          _buildCreatorTab(
                            'Invited',
                            controller.selectedTab.value == 2,
                            () => controller.changeTab(2),
                            campaign.invitedCreators.length,
                          ),
                        ],
                      )),

                      const SizedBox(height: 16),

                      // Creator list
                      Obx(() {
                        List<String> creatorIds = [];
                        String emptyMessage = '';

                        switch (controller.selectedTab.value) {
                          case 0:
                            creatorIds = campaign.selectedCreators;
                            emptyMessage = 'No creators selected yet';
                            break;
                          case 1:
                            creatorIds = campaign.appliedCreators;
                            emptyMessage = 'No creators have applied yet';
                            break;
                          case 2:
                            creatorIds = campaign.invitedCreators;
                            emptyMessage = 'No creators invited yet';
                            break;
                        }

                        if (creatorIds.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                emptyMessage,
                                style: AppStyles.body1.copyWith(
                                  color: AppColors.grey,
                                ),
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: creatorIds.length,
                          itemBuilder: (context, index) {
                            final creatorId = creatorIds[index];
                            return FutureBuilder(
                              future: controller.getCreatorDetails(creatorId),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                if (!snapshot.hasData || snapshot.data == null) {
                                  return const SizedBox();
                                }

                                final creator = snapshot.data!;
                                
                                return CreatorListItem(
                                  creator: creator,
                                  campaignId: campaign.id,
                                  status: controller.selectedTab.value == 0
                                      ? 'Selected'
                                      : controller.selectedTab.value == 1
                                          ? 'Applied'
                                          : 'Invited',
                                  onTap: () => controller.viewCreatorProfile(creator.id),
                                  onSelect: controller.selectedTab.value == 1
                                      ? () => controller.selectCreator(creator.id)
                                      : null,
                                  onCollaborate: controller.selectedTab.value == 0
                                      ? () => controller.startCollaboration(creator.id)
                                      : null,
                                );
                              },
                            );
                          },
                        );
                      }),

                      if (controller.selectedTab.value == 2) ...[
                        const SizedBox(height: 16),
                        CustomButton(
                          label: 'Invite More Creators',
                          onPressed: () => controller.navigateToInviteCreators(),
                          icon: Icons.person_add,
                        ),
                      ],
                    ],

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        if (controller.isLoading.value || controller.campaign.value == null) {
          return const SizedBox.shrink();
        }

        final campaign = controller.campaign.value!;
        final bool isBrand = controller.userType.value == AppConstants.userTypeBrand;
        final bool isDeadlinePassed = campaign.deadline.isBefore(DateTime.now());
        if (isBrand) {
          return const SizedBox.shrink(); // No bottom action for brands
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Obx(() {
              if (isDeadlinePassed) {
                return const Text(
                  'This campaign is no longer accepting applications',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }

              if (controller.hasApplied.value) {
                return Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'You have applied to this campaign',
                      style: AppStyles.body1.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              }

              return CustomButton(
                label: 'Apply to This Campaign',
                onPressed: () => controller.applyCampaign(),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String value, IconData icon,
      {bool isWarning = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isWarning ? AppColors.error : AppColors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: AppStyles.caption.copyWith(
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppStyles.heading3.copyWith(
                color: isWarning ? AppColors.error : AppColors.dark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatorTab(String title, bool isSelected, VoidCallback onTap, int count) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Text(
              '$title ($count)',
              style: AppStyles.body1.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 3,
              color: isSelected ? AppColors.primary : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}