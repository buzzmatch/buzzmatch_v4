import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_styles.dart';
import '../../../../constants/app_constants.dart';

class BrandStatsCard extends StatelessWidget {
  final int campaignsCount;
  final int collaborationsCount;
  final double walletBalance;
  
  const BrandStatsCard({
    super.key,
    required this.campaignsCount,
    required this.collaborationsCount,
    required this.walletBalance,
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
      child: Padding(
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
                // Campaigns
                _buildStatItem(
                  context,
                  Icons.campaign,
                  campaignsCount.toString(),
                  'Campaigns',
                ),
                
                // Collaborations
                _buildStatItem(
                  context,
                  Icons.handshake,
                  collaborationsCount.toString(),
                  'Collaborations',
                ),
                
                // Wallet
                _buildStatItem(
                  context,
                  Icons.account_balance_wallet,
                  '${AppConstants.currency} ${walletBalance.toStringAsFixed(2)}',
                  'Balance',
                ),
              ],
            ),
          ],
        ),
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