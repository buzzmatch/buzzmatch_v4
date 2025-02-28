import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_styles.dart';
import '../../../../constants/app_constants.dart';
import '../../../../models/campaign_model.dart';

class BrandCampaignCard extends StatelessWidget {
  final CampaignModel campaign;
  final VoidCallback onTap;
  
  const BrandCampaignCard({
    super.key,
    required this.campaign,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDeadlinePassed = campaign.deadline.isBefore(DateTime.now());
    
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campaign name and budget
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      campaign.campaignName,
                      style: AppStyles.heading3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      '${AppConstants.currency} ${campaign.budget.toStringAsFixed(0)}',
                      style: AppStyles.body2.copyWith(
                        color: isDeadlinePassed ? AppColors.error : AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Deadline
              Text(
                'Deadline: ${DateFormat('MMM dd, yyyy').format(campaign.deadline)}',
                style: AppStyles.body2.copyWith(
                  color: isDeadlinePassed ? AppColors.error : AppColors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}