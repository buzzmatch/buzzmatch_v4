import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_styles.dart';
import '../../constants/app_constants.dart';
import '../../models/campaign_model.dart';
import '../../widgets/common/custom_button.dart';

class CampaignListItem extends StatelessWidget {
  final CampaignModel campaign;
  final String userType;
  final VoidCallback onTap;
  final VoidCallback? onApply;
  
  const CampaignListItem({
    super.key,
    required this.campaign,
    required this.userType,
    required this.onTap,
    this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDeadlinePassed = campaign.deadline.isBefore(DateTime.now());
    final bool isBrand = userType == AppConstants.userTypeBrand;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campaign header with status
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: campaign.isActive
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Brand logo or initials
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          image: campaign.brandLogo != null
                              ? DecorationImage(
                                  image: NetworkImage(campaign.brandLogo!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: campaign.brandLogo == null
                            ? Center(
                                child: Text(
                                  campaign.brandName.substring(0, 1),
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        campaign.brandName,
                        style: AppStyles.body2.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  // Status chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      campaign.isActive ? 'Active' : 'Inactive',
                      style: AppStyles.caption.copyWith(
                        color: campaign.isActive
                            ? AppColors.primary
                            : AppColors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Campaign details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Campaign name
                  Text(
                    campaign.campaignName,
                    style: AppStyles.heading3,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Product name
                  Text(
                    campaign.productName,
                    style: AppStyles.body2.copyWith(
                      color: AppColors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Budget and stats
                  Row(
                    children: [
                      // Budget
                      const Icon(
                        Icons.attach_money,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${AppConstants.currency} ${campaign.budget.toStringAsFixed(0)}',
                        style: AppStyles.body2.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Deadline
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: isDeadlinePassed ? AppColors.error : AppColors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM dd, yyyy').format(campaign.deadline),
                        style: AppStyles.caption.copyWith(
                          color: isDeadlinePassed ? AppColors.error : AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Content types
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: campaign.requiredContentTypes.map((type) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          type,
                          style: AppStyles.caption.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Stats for brands or apply button for creators
                  isBrand
                      ? _buildBrandStats()
                      : _buildCreatorActions(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBrandStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          'Invited',
          campaign.invitedCreators.length.toString(),
          Icons.person_add,
        ),
        _buildStatItem(
          'Applied',
          campaign.appliedCreators.length.toString(),
          Icons.how_to_reg,
        ),
        _buildStatItem(
          'Selected',
          campaign.selectedCreators.length.toString(),
          Icons.check_circle,
        ),
      ],
    );
  }
  
  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.grey,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppStyles.body1.copyWith(
            fontWeight: FontWeight.bold,
          ),
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
  
  Widget _buildCreatorActions() {
    // Check if campaign deadline has passed
    final bool isDeadlinePassed = campaign.deadline.isBefore(DateTime.now());
    
    // Check if creator already applied (this is a placeholder, actual check is in controller)
    const bool alreadyApplied = false; // campaign.appliedCreators.contains(creatorId)
    
    if (isDeadlinePassed) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        width: double.infinity,
        alignment: Alignment.center,
        child: Text(
          'Deadline has passed',
          style: AppStyles.body2.copyWith(
            color: AppColors.error,
          ),
        ),
      );
    }
    
    if (alreadyApplied) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        width: double.infinity,
        alignment: Alignment.center,
        child: Text(
          'Application submitted',
          style: AppStyles.body2.copyWith(
            color: AppColors.success,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
    
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            label: 'Apply Now',
            onPressed: onApply ?? () {},
            height: 40,
          ),
        ),
        const SizedBox(width: 8),
        CustomButton(
          label: 'Details',
          onPressed: onTap,
          isOutlined: true,
          height: 40,
          fullWidth: false,
        ),
      ],
    );
  }
}