import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_styles.dart';
import '../../../models/creator_model.dart';
import '../../../widgets/common/custom_button.dart';

class CreatorListItem extends StatelessWidget {
  final CreatorModel creator;
  final String campaignId;
  final String status; // 'Selected', 'Applied', or 'Invited'
  final VoidCallback onTap;
  final VoidCallback? onSelect;
  final VoidCallback? onCollaborate;
  
  const CreatorListItem({
    super.key,
    required this.creator,
    required this.campaignId,
    required this.status,
    required this.onTap,
    this.onSelect,
    this.onCollaborate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Creator image
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primary.withOpacity(0.2),
                backgroundImage: creator.profileImage != null
                    ? CachedNetworkImageProvider(creator.profileImage!) as ImageProvider
                    : null,
                child: creator.profileImage == null
                    ? Text(
                        creator.fullName.substring(0, 1),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              
              const SizedBox(width: 16),
              
              // Creator info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      creator.fullName,
                      style: AppStyles.heading3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Row(
                      children: [
                        const Icon(
                          Icons.category,
                          size: 14,
                          color: AppColors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          creator.mainCategory,
                          style: AppStyles.caption.copyWith(
                            color: AppColors.grey,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.videocam,
                          size: 14,
                          color: AppColors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          creator.contentType,
                          style: AppStyles.caption.copyWith(
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Status and action buttons
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status,
                            style: AppStyles.caption.copyWith(
                              color: _getStatusColor(),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // Action buttons based on status
                        if (status == 'Applied' && onSelect != null)
                          SizedBox(
                            height: 32,
                            child: CustomButton(
                              label: 'Select',
                              onPressed: onSelect ?? () {},
                              color: AppColors.success,
                              height: 32,
                              fullWidth: false,
                            ),
                          ),
                        
                        if (status == 'Selected' && onCollaborate != null) ...[
                          const SizedBox(width: 8),
                          SizedBox(
                            height: 32,
                            child: CustomButton(
                              label: 'Collaborate',
                              onPressed: onCollaborate ?? () {},
                              height: 32,
                              fullWidth: false,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Color _getStatusColor() {
    switch (status) {
      case 'Selected':
        return AppColors.success;
      case 'Applied':
        return AppColors.primary;
      case 'Invited':
        return AppColors.warning;
      default:
        return AppColors.grey;
    }
  }
}