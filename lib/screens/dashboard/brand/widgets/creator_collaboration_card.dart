import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_styles.dart';
import '../../../../constants/app_constants.dart';
import '../../../../models/collaboration_model.dart';
import '../../../../widgets/common/status_badge.dart';
import '../../../../services/firestore_service.dart';

class CreatorCollaborationCard extends StatelessWidget {
  final CollaborationModel collaboration;
  final VoidCallback onTap;
  
  const CreatorCollaborationCard({
    super.key,
    required this.collaboration,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = Get.find<FirestoreService>();
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Column(
          children: [
            // Header with status
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Status badge
                  StatusBadge(status: collaboration.status),
                  
                  // Updated time
                  Text(
                    'Updated ${timeago.format(collaboration.updatedAt, allowFromNow: true)}',
                    style: AppStyles.caption.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
            
            // Collaboration details
            Padding(
              padding: const EdgeInsets.all(16),
              child: FutureBuilder(
                future: firestoreService.getCampaign(collaboration.campaignId),
                builder: (context, snapshot) {
                  String campaignName = 'Loading...';
                  String brandName = '';
                  
                  if (snapshot.hasData && snapshot.data != null) {
                    final campaignData = snapshot.data!.data() as Map<String, dynamic>;
                    campaignName = campaignData['campaignName'] ?? 'Unknown Campaign';
                    brandName = campaignData['brandName'] ?? 'Unknown Brand';
                  }
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Campaign name
                      Text(
                        campaignName,
                        style: AppStyles.heading3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      if (brandName.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'with $brandName',
                          style: AppStyles.body2.copyWith(
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 12),
                      
                      // Budget
                      Row(
                        children: [
                          const Icon(
                            Icons.attach_money,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${AppConstants.currency} ${collaboration.budget.toStringAsFixed(0)}',
                            style: AppStyles.body2.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.dark,
                            ),
                          ),
                          
                          // Payment status
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: collaboration.isPaid
                                  ? AppColors.success.withOpacity(0.1)
                                  : AppColors.warning.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              collaboration.isPaid ? 'Paid' : 'Pending',
                              style: AppStyles.caption.copyWith(
                                color: collaboration.isPaid
                                    ? AppColors.success
                                    : AppColors.warning,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Next action based on status
                      _buildNextAction(collaboration.status),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNextAction(String status) {
    IconData icon;
    String actionText;
    Color color;
    
    switch (status) {
      case AppConstants.statusMatched:
        icon = Icons.description_outlined;
        actionText = 'Sign contract to proceed';
        color = AppColors.info;
        break;
      case AppConstants.statusContractSigned:
        icon = Icons.inventory_2_outlined;
        actionText = 'Waiting for product to be shipped';
        color = AppColors.grey;
        break;
      case AppConstants.statusProductShipped:
        icon = Icons.camera_alt_outlined;
        actionText = 'Start creating content';
        color = AppColors.primary;
        break;
      case AppConstants.statusContentInProgress:
        icon = Icons.cloud_upload_outlined;
        actionText = 'Submit your content';
        color = AppColors.primary;
        break;
      case AppConstants.statusSubmitted:
        icon = Icons.hourglass_bottom;
        actionText = 'Waiting for brand review';
        color = AppColors.grey;
        break;
      case AppConstants.statusRevision:
        icon = Icons.edit_outlined;
        actionText = 'Apply revisions to content';
        color = AppColors.warning;
        break;
      case AppConstants.statusApproved:
        icon = Icons.thumb_up_outlined;
        actionText = 'Content approved! Waiting for payment';
        color = AppColors.success;
        break;
      case AppConstants.statusPaymentReleased:
        icon = Icons.payments_outlined;
        actionText = 'Payment released';
        color = AppColors.success;
        break;
      default:
        icon = Icons.info_outline;
        actionText = 'Unknown status';
        color = AppColors.grey;
    }
    
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: color,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            actionText,
            style: AppStyles.body2.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}