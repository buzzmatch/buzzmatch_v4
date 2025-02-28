import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../models/wallet_models.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/payment_service.dart';
import '../../constants/app_constants.dart';
import '../../routes/app_pages.dart';
import '../../widgets/common/custom_button.dart';

class WalletController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final PaymentService _paymentService = Get.find<PaymentService>();
  
  // Observable variables
  final RxBool isLoading = true.obs;
  final RxString userType = ''.obs;
  final RxString userId = ''.obs;
  
  // Wallet data
  final RxDouble walletBalance = 0.0.obs;
  final RxDouble pendingBalance = 0.0.obs;
  final RxDouble totalEarned = 0.0.obs;
  final RxDouble totalSpent = 0.0.obs;
  final RxDouble currentMonthSpent = 0.0.obs;
  
  // Transactions
  final RxList<Map<String, dynamic>> recentTransactions = <Map<String, dynamic>>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    
    // Determine user type and ID
    userType.value = _authService.currentUser.value?.userType ?? '';
    
    if (userType.value == AppConstants.userTypeBrand) {
      userId.value = _authService.currentBrand.value?.id ?? '';
    } else {
      userId.value = _authService.currentCreator.value?.id ?? '';
    }
    
    if (userId.value.isNotEmpty) {
      loadWalletData();
    } else {
      isLoading.value = false;
    }
  }
  
  Future<void> loadWalletData() async {
    try {
      isLoading.value = true;
      
      // Get wallet data
      final walletDoc = await _firestoreService.getWallet(userId.value);
      if (walletDoc != null) {
        final wallet = WalletModel.fromFirestore(walletDoc);
        
        walletBalance.value = wallet.balance;
        pendingBalance.value = wallet.pendingBalance;
        totalEarned.value = wallet.totalEarned;
        totalSpent.value = wallet.totalSpent;
      }
      
      // Get recent transactions
      final transactionDocs = await _firestoreService.getUserTransactions(userId.value);
      
      final List<Map<String, dynamic>> transactions = [];
      
      for (var doc in transactionDocs) {
        final data = doc.data() as Map<String, dynamic>;
        
        transactions.add({
          'id': doc.id,
          'type': data['type'] ?? '',
          'amount': data['amount']?.toDouble() ?? 0.0,
          'status': data['status'] ?? '',
          'paymentMethod': data['paymentMethod'] ?? '',
          'userType': data['userType'] ?? '',
          'date': data['createdAt'] != null 
              ? (data['createdAt'] as Timestamp).toDate() 
              : DateTime.now(),
          'description': data['description'] ?? '',
          'collaborationId': data['collaborationId'],
          'campaignId': data['campaignId'],
        });
      }
      
      // Sort by date (newest first)
      transactions.sort((a, b) => b['date'].compareTo(a['date']));
      
      // Only show recent transactions (last 10)
      recentTransactions.value = transactions.take(10).toList();
      
      // Calculate current month spent (for brands)
      if (userType.value == AppConstants.userTypeBrand) {
        final now = DateTime.now();
        final currentMonth = DateTime(now.year, now.month, 1);
        
        double monthTotal = 0.0;
        for (var transaction in transactions) {
          if (transaction['date'].isAfter(currentMonth) && 
              transaction['type'] == 'payment' &&
              transaction['status'] == AppConstants.paymentCompleted) {
            monthTotal += transaction['amount']?.toDouble() ?? 0.0;
          }
        }
        
        currentMonthSpent.value = monthTotal;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load wallet data: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> refreshWallet() async {
    await loadWalletData();
  }
  
void navigateToTransactionHistory() {
  Get.toNamed(Routes.TRANSACTION_HISTORY);
}

  
  void showAddFundsDialog() {
    final TextEditingController amountController = TextEditingController();
    const List<String> paymentMethods = AppConstants.paymentMethods;
    final RxString selectedMethod = paymentMethods.first.obs;
    
    Get.dialog(
      AlertDialog(
        title: const Text('Add Funds'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount field
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Amount (${AppConstants.currency})',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            
            const SizedBox(height: 16),
            
            // Payment method selection
            const Text('Select Payment Method'),
            const SizedBox(height: 8),
            Obx(() => Column(
              children: paymentMethods.map((method) {
                return RadioListTile<String>(
                  title: Text(method),
                  value: method,
                  groupValue: selectedMethod.value,
                  onChanged: (value) {
                    if (value != null) {
                      selectedMethod.value = value;
                    }
                  },
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                );
              }).toList(),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text.trim());
              if (amount == null || amount <= 0) {
                Get.snackbar('Error', 'Please enter a valid amount');
                return;
              }
              
              Get.back();
              processAddFunds(amount, selectedMethod.value);
            },
            child: const Text('Add Funds'),
          ),
        ],
      ),
    );
  }
  
  void showWithdrawDialog() {
    final TextEditingController amountController = TextEditingController();
    const List<String> paymentMethods = AppConstants.paymentMethods;
    final RxString selectedMethod = paymentMethods.first.obs;
    
    Get.dialog(
      AlertDialog(
        title: const Text('Withdraw Funds'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Available balance
            Text(
              'Available Balance: ${AppConstants.currency} ${walletBalance.value.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Amount field
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Amount (${AppConstants.currency})',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            
            const SizedBox(height: 16),
            
            // Payment method selection
            const Text('Select Payment Method'),
            const SizedBox(height: 8),
            Obx(() => Column(
              children: paymentMethods.map((method) {
                return RadioListTile<String>(
                  title: Text(method),
                  value: method,
                  groupValue: selectedMethod.value,
                  onChanged: (value) {
                    if (value != null) {
                      selectedMethod.value = value;
                    }
                  },
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                );
              }).toList(),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text.trim());
              if (amount == null || amount <= 0) {
                Get.snackbar('Error', 'Please enter a valid amount');
                return;
              }
              
              if (amount > walletBalance.value) {
                Get.snackbar('Error', 'Insufficient balance');
                return;
              }
              
              Get.back();
              processWithdrawal(amount, selectedMethod.value);
            },
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
  }
  
  Future<void> processAddFunds(double amount, String paymentMethod) async {
    // Show loading dialog
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(),
      ),
      barrierDismissible: false,
    );
    
    try {
      // Process deposit
      final transactionId = await _paymentService.processDeposit(
        userId: userId.value,
        userType: userType.value,
        amount: amount,
        paymentMethod: paymentMethod,
        description: 'Wallet deposit',
      );
      
      // Close loading dialog
      Get.back();
      
      if (transactionId != null) {
        // Show success dialog
        Get.dialog(
          AlertDialog(
            title: const Text('Deposit Successful'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  '${AppConstants.currency} ${amount.toStringAsFixed(2)} has been added to your wallet.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back();
                  refreshWallet();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      Get.back();
      
      Get.snackbar('Error', 'Failed to process deposit: ${e.toString()}');
    }
  }
  
  Future<void> processWithdrawal(double amount, String paymentMethod) async {
    // Show loading dialog
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(),
      ),
      barrierDismissible: false,
    );
    
    try {
      // Process withdrawal
      final transactionId = await _paymentService.processWithdrawal(
        userId: userId.value,
        userType: userType.value,
        amount: amount,
        paymentMethod: paymentMethod,
        description: 'Wallet withdrawal',
      );
      
      // Close loading dialog
      Get.back();
      
      if (transactionId != null) {
        // Show success dialog
        Get.dialog(
          AlertDialog(
            title: const Text('Withdrawal Requested'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  '${AppConstants.currency} ${amount.toStringAsFixed(2)} withdrawal has been processed.\n\nFunds will be transferred to your account within 1-3 business days.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back();
                  refreshWallet();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      Get.back();
      
      Get.snackbar('Error', 'Failed to process withdrawal: ${e.toString()}', backgroundColor: Colors.red);
    }
  }
}