import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_styles.dart';
import '../../constants/app_constants.dart';
import '../../widgets/common/custom_button.dart';
import 'wallet_controller.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WalletController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Wallet'),
        actions: [
          IconButton(
            onPressed: () => controller.navigateToTransactionHistory(),
            icon: const Icon(Icons.history),
            tooltip: 'Transaction History',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.refreshWallet(),
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Balance card
                _buildBalanceCard(context, controller),

                const SizedBox(height: 24),

                // Action buttons
                _buildActionButtons(context, controller),

                const SizedBox(height: 24),

                // Recent transactions
                const Text(
                  'Recent Transactions',
                  style: AppStyles.heading3,
                ),
                const SizedBox(height: 16),
                
                Obx(() {
                  if (controller.recentTransactions.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 64,
                              color: AppColors.grey.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No transactions yet',
                              style: AppStyles.body1.copyWith(
                                color: AppColors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.recentTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = controller.recentTransactions[index];
                      return _buildTransactionItem(context, transaction);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBalanceCard(BuildContext context, WalletController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User type badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              controller.userType.value == AppConstants.userTypeBrand
                  ? 'Brand Account'
                  : 'Creator Account',
              style: AppStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Available balance
          Text(
            'Available Balance',
            style: AppStyles.body2.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${AppConstants.currency} ${controller.walletBalance.value.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // Additional balances for creators
          if (controller.userType.value == AppConstants.userTypeCreator)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pending',
                      style: AppStyles.caption.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${AppConstants.currency} ${controller.pendingBalance.value.toStringAsFixed(2)}',
                      style: AppStyles.body1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total Earned',
                      style: AppStyles.caption.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${AppConstants.currency} ${controller.totalEarned.value.toStringAsFixed(2)}',
                      style: AppStyles.body1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),

          // Additional balances for brands
          if (controller.userType.value == AppConstants.userTypeBrand)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This Month',
                      style: AppStyles.caption.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${AppConstants.currency} ${controller.currentMonthSpent.value.toStringAsFixed(2)}',
                      style: AppStyles.body1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total Spent',
                      style: AppStyles.caption.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${AppConstants.currency} ${controller.totalSpent.value.toStringAsFixed(2)}',
                      style: AppStyles.body1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WalletController controller) {
    if (controller.userType.value == AppConstants.userTypeBrand) {
      // Brand actions
      return CustomButton(
        label: 'Add Funds',
        onPressed: () => controller.showAddFundsDialog(),
        icon: Icons.add_circle_outline,
      );
    } else {
      // Creator actions
      return Row(
        children: [
          Expanded(
            child: CustomButton(
              label: 'Add Funds',
              onPressed: () => controller.showAddFundsDialog(),
              icon: Icons.add_circle_outline,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CustomButton(
              label: 'Withdraw',
              onPressed: () => controller.showWithdrawDialog(),
              icon: Icons.account_balance_wallet,
              isOutlined: true,
            ),
          ),
        ],
      );
    }
  }

  Widget _buildTransactionItem(BuildContext context, Map<String, dynamic> transaction) {
    // Determine icon and color based on transaction type and status
    IconData icon;
    Color color;
    bool isPositive = false;

    switch (transaction['type']) {
      case 'deposit':
        icon = Icons.arrow_downward;
        color = AppColors.success;
        isPositive = true;
        break;
      case 'withdrawal':
        icon = Icons.arrow_upward;
        color = AppColors.primary;
        isPositive = false;
        break;
      case 'payment':
        if (transaction['userType'] == AppConstants.userTypeBrand) {
          icon = Icons.shopping_bag;
          color = AppColors.info;
          isPositive = false;
        } else {
          icon = Icons.paid;
          color = AppColors.success;
          isPositive = true;
        }
        break;
      default:
        icon = Icons.swap_horiz;
        color = AppColors.grey;
        isPositive = false;
    }

    // Apply status color for pending transactions
    if (transaction['status'] == AppConstants.paymentPending) {
      color = AppColors.warning;
    } else if (transaction['status'] == AppConstants.paymentFailed) {
      color = AppColors.error;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Row(
        children: [
          // Transaction icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Transaction details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getTransactionTitle(transaction),
                  style: AppStyles.body1.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM dd, yyyy, HH:mm').format(transaction['date']),
                  style: AppStyles.caption.copyWith(
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
          
          // Transaction amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isPositive ? '+' : '-'} ${AppConstants.currency} ${transaction['amount'].toStringAsFixed(2)}',
                style: AppStyles.body1.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isPositive ? AppColors.success : AppColors.dark,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(transaction['status']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  transaction['status'],
                  style: AppStyles.caption.copyWith(
                    color: _getStatusColor(transaction['status']),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getTransactionTitle(Map<String, dynamic> transaction) {
    switch (transaction['type']) {
      case 'deposit':
        return 'Added Funds';
      case 'withdrawal':
        return 'Withdrawal';
      case 'payment':
        if (transaction['userType'] == AppConstants.userTypeBrand) {
          return 'Payment for Collaboration';
        } else {
          return 'Received Payment';
        }
      default:
        return 'Transaction';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case AppConstants.paymentPending:
        return AppColors.warning;
      case AppConstants.paymentCompleted:
        return AppColors.success;
      case AppConstants.paymentFailed:
        return AppColors.error;
      case AppConstants.paymentRefunded:
        return AppColors.info;
      default:
        return AppColors.grey;
    }
  }
}