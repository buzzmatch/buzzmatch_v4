import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_styles.dart';
import '../../../../constants/app_constants.dart';

class CreatorStatsCard extends StatelessWidget {
  final int collaborationsCount;
  final int completedCollaborationsCount;
  final double walletBalance;
  final double pendingBalance;
  
  const CreatorStatsCard({
    super.key,
    required this.collaborationsCount,
    required this.completedCollaborationsCount,
    required this.walletBalance,
    required this.pendingBalance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Your Stats',
                  style: AppStyles.heading3.copyWith(
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Stats in a row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // All Collaborations
                    _buildStatItem(
                      context,
                      Icons.handshake,
                      collaborationsCount.toString(),
                      'All Collabs',
                    ),
                    
                    // Completed Collaborations
                    _buildStatItem(
                      context,
                      Icons.check_circle,
                      completedCollaborationsCount.toString(),
                      'Completed',
                    ),
                    
                    // Completion Rate
                    _buildStatItem(
                      context,
                      Icons.bar_chart,
                      collaborationsCount > 0
                          ? '${(completedCollaborationsCount / collaborationsCount * 100).toStringAsFixed(0)}%'
                          : '0%',
                      'Success Rate',
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Wallet section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Wallet Balance',
                      style: AppStyles.body2.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${AppConstants.currency} ${walletBalance.toStringAsFixed(2)}',
                      style: AppStyles.heading2.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Pending',
                      style: AppStyles.body2.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${AppConstants.currency} ${pendingBalance.toStringAsFixed(2)}',
                      style: AppStyles.heading2.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppStyles.heading3.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppStyles.caption.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}