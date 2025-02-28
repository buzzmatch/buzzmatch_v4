import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_styles.dart';
import '../../constants/app_constants.dart';
import '../../widgets/common/custom_button.dart';
import 'profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

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

        return CustomScrollView(
          slivers: [
            // App Bar with profile image
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  controller.userType.value == AppConstants.userTypeBrand
                      ? controller.brand.value?.companyName ?? 'Brand'
                      : controller.creator.value?.fullName ?? 'Creator',
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
                background: Container(
                  color: AppColors.primary,
                  child: Center(
                    child: controller.userType.value == AppConstants.userTypeBrand
                        ? _buildBrandProfileImage(controller)
                        : _buildCreatorProfileImage(controller),
                  ),
                ),
              ),
              actions: [
                // Settings
                IconButton(
                  onPressed: () => controller.navigateToSettings(),
                  icon: const Icon(Icons.settings),
                  tooltip: 'Settings',
                ),
                
                // Logout
                IconButton(
                  onPressed: () => controller.showLogoutConfirmation(),
                  icon: const Icon(Icons.logout),
                  tooltip: 'Logout',
                ),
              ],
            ),

            // Profile content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Edit profile button
                    CustomButton(
                      label: 'Edit Profile',
                      onPressed: () => controller.navigateToEditProfile(),
                      icon: Icons.edit,
                      isOutlined: true,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Brand-specific profile
                    if (controller.userType.value == AppConstants.userTypeBrand)
                      _buildBrandProfile(context, controller),
                    
                    // Creator-specific profile
                    if (controller.userType.value == AppConstants.userTypeCreator)
                      _buildCreatorProfile(context, controller),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
  
  Widget _buildBrandProfileImage(ProfileController controller) {
    if (controller.brand.value?.logoUrl != null) {
      return CircleAvatar(
        radius: 60,
        backgroundColor: Colors.white,
        backgroundImage: CachedNetworkImageProvider(
          controller.brand.value!.logoUrl!,
        ),
      );
    } else {
      return CircleAvatar(
        radius: 60,
        backgroundColor: Colors.white,
        child: Text(
          controller.brand.value?.companyName.substring(0, 1).toUpperCase() ?? 'B',
          style: const TextStyle(
            fontSize: 60,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      );
    }
  }
  
  Widget _buildCreatorProfileImage(ProfileController controller) {
    if (controller.creator.value?.profileImage != null) {
      return CircleAvatar(
        radius: 60,
        backgroundColor: Colors.white,
        backgroundImage: CachedNetworkImageProvider(
          controller.creator.value!.profileImage!,
        ),
      );
    } else {
      return CircleAvatar(
        radius: 60,
        backgroundColor: Colors.white,
        child: Text(
          controller.creator.value?.fullName.substring(0, 1).toUpperCase() ?? 'C',
          style: const TextStyle(
            fontSize: 60,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      );
    }
  }
  
  Widget _buildBrandProfile(BuildContext context, ProfileController controller) {
    final brand = controller.brand.value;
    if (brand == null) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Basic info
        _buildInfoCard(
          context,
          title: 'Basic Information',
          children: [
            _buildInfoItem('Business Category', brand.businessCategory),
            _buildInfoItem('Email', brand.email),
            _buildInfoItem('Phone', brand.phone),
            _buildInfoItem('Country', brand.country),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Description
        if (brand.description != null && brand.description!.isNotEmpty)
          _buildInfoCard(
            context,
            title: 'About Us',
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  brand.description!,
                  style: AppStyles.body1,
                ),
              ),
            ],
          ),
        
        const SizedBox(height: 24),
        
        // Website
        if (brand.websiteUrl != null && brand.websiteUrl!.isNotEmpty)
          _buildInfoCard(
            context,
            title: 'Website',
            children: [
              InkWell(
                onTap: () => controller.openUrl(brand.websiteUrl!),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.language,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          brand.websiteUrl!,
                          style: AppStyles.body1.copyWith(
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        
        const SizedBox(height: 24),
        
        // Social links
        if (brand.socialLinks.isNotEmpty)
          _buildInfoCard(
            context,
            title: 'Social Media',
            children: [
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: brand.socialLinks.map((link) {
                  return InkWell(
                    onTap: () => controller.openUrl(link),
                    child: Chip(
                      avatar: const Icon(
                        Icons.link,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      label: Text(
                        _getSocialPlatformName(link),
                        style: AppStyles.body2.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        
        const SizedBox(height: 24),
        
        // Statistics
        _buildInfoCard(
          context,
          title: 'Statistics',
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  controller.campaignsCount.value.toString(),
                  'Campaigns',
                  Icons.campaign,
                ),
                _buildStatItem(
                  controller.collaborationsCount.value.toString(),
                  'Collaborations',
                  Icons.handshake,
                ),
                _buildStatItem(
                  controller.completedCount.value.toString(),
                  'Completed',
                  Icons.check_circle,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildCreatorProfile(BuildContext context, ProfileController controller) {
    final creator = controller.creator.value;
    if (creator == null) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Basic info
        _buildInfoCard(
          context,
          title: 'Basic Information',
          children: [
            _buildInfoItem('Content Type', creator.contentType),
            _buildInfoItem('Main Category', creator.mainCategory),
            _buildInfoItem('Email', creator.email),
            _buildInfoItem('Phone', creator.phone),
            _buildInfoItem('Country', creator.country),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Bio
        if (creator.bio != null && creator.bio!.isNotEmpty)
          _buildInfoCard(
            context,
            title: 'Bio',
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  creator.bio!,
                  style: AppStyles.body1,
                ),
              ),
            ],
          ),
        
        const SizedBox(height: 24),
        
        // Statistics and metrics
        _buildInfoCard(
          context,
          title: 'Statistics',
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  controller.collaborationsCount.value.toString(),
                  'Collaborations',
                  Icons.handshake,
                ),
                _buildStatItem(
                  controller.completedCount.value.toString(),
                  'Completed',
                  Icons.check_circle,
                ),
                _buildStatItem(
                  creator.stats['followers']?.toString() ?? '0',
                  'Followers',
                  Icons.people,
                ),
              ],
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Portfolio
        if (creator.portfolioUrls.isNotEmpty) ...[
          const Text(
            'Portfolio',
            style: AppStyles.heading3,
          ),
          const SizedBox(height: 16),
          StaggeredGrid.count(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: creator.portfolioUrls.map((url) {
              return StaggeredGridTile.count(
                crossAxisCellCount: 1,
                mainAxisCellCount: 1,
                child: GestureDetector(
                  onTap: () => controller.viewPortfolioItem(url),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(url),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
        
        const SizedBox(height: 24),
        
        // Social links
        if (creator.socialLinks.isNotEmpty)
          _buildInfoCard(
            context,
            title: 'Social Media',
            children: [
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: creator.socialLinks.map((link) {
                  return InkWell(
                    onTap: () => controller.openUrl(link),
                    child: Chip(
                      avatar: const Icon(
                        Icons.link,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      label: Text(
                        _getSocialPlatformName(link),
                        style: AppStyles.body2.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
      ],
    );
  }
  
  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppStyles.heading3,
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
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
            children: children,
          ),
        ),
      ],
    );
  }
  
  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppStyles.body2.copyWith(
                color: AppColors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppStyles.body1,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppStyles.heading3,
        ),
        Text(
          label,
          style: AppStyles.caption.copyWith(
            color: AppColors.grey,
          ),
        ),
      ],
    );
  }
  
  String _getSocialPlatformName(String url) {
    if (url.contains('facebook')) return 'Facebook';
    if (url.contains('instagram')) return 'Instagram';
    if (url.contains('twitter')) return 'Twitter';
    if (url.contains('linkedin')) return 'LinkedIn';
    if (url.contains('tiktok')) return 'TikTok';
    if (url.contains('youtube')) return 'YouTube';
    return 'Social';
  }
}