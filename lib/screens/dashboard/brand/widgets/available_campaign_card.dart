import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_styles.dart';
import '../../../../constants/app_constants.dart';
import '../../../../models/campaign_model.dart';

class AvailableCampaignCard extends StatelessWidget {
  final CampaignModel campaign;
  final VoidCallback onTap;
  
  const AvailableCampaignCard({
    super.key,
    required this.campaign,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDeadlineSoon = campaign.deadline.difference(DateTime.now()).inDays < 7;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 250,
        margin: const EdgeInsets.only(right: 16),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Brand header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  // Brand logo
                  Container(
                    width: 40,
                    height: 40,
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
                  const SizedBox(width: 12),
                  
                  // Brand name
                  Expanded(
                    child: Text(
                      campaign.brandName,
                      style: AppStyles.body1.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                  
                  const SizedBox(height: 8),
                  
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
                        '${AppConstants.currency} ${campaign.budget.toStringAsFixed(0)}',
                        style: AppStyles.body2.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.dark,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
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
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Deadline
                  Row(
                    children: [
                      Icon(
                        Icons.timer,
                        size: 16,
                        color: isDeadlineSoon ? AppColors.error : AppColors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Deadline: ${DateFormat('MMM dd, yyyy').format(campaign.deadline)}',
                        style: AppStyles.caption.copyWith(
                          color: isDeadlineSoon ? AppColors.error : AppColors.grey,
                          fontWeight: isDeadlineSoon ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Posted time
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppColors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Posted ${timeago.format(campaign.createdAt, allowFromNow: true)}',
                        style: AppStyles.caption.copyWith(
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}