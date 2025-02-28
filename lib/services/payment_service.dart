import 'package:get/get.dart';

import '../models/wallet_models.dart';
import '../constants/app_constants.dart';
import 'firestore_service.dart';

class PaymentService extends GetxService {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  
  // Process deposit to wallet
  Future<String?> processDeposit({
    required String userId,
    required String userType,
    required double amount,
    required String paymentMethod,
    String? description,
  }) async {
    try {
      // Create pending transaction
      final transaction = TransactionModel(
        id: '',
        userId: userId,
        userType: userType,
        type: 'deposit',
        amount: amount,
        status: AppConstants.paymentPending,
        paymentMethod: paymentMethod,
        description: description ?? 'Wallet deposit',
        createdAt: DateTime.now(),
      );
      
      final transactionId = await _firestoreService.createTransaction(transaction);
      
      // Here you would integrate with actual payment provider (Stripe, PayPal, etc.)
      // This is a placeholder for the payment process
      
      // For demo purposes, we'll just mark the transaction as completed
      await _firestoreService.updateTransactionStatus(
        transactionId, 
        AppConstants.paymentCompleted,
        completedAt: DateTime.now(),
      );
      
      // Update wallet balance
      final walletDoc = await _firestoreService.getWallet(userId);
      if (walletDoc != null) {
        final wallet = WalletModel.fromFirestore(walletDoc);
        final updatedWallet = wallet.copyWith(
          balance: wallet.balance + amount,
          updatedAt: DateTime.now(),
        );
        
        await _firestoreService.updateWallet(updatedWallet);
      }
      
      return transactionId;
    } catch (e) {
      Get.snackbar('Error', 'Failed to process deposit');
      return null;
    }
  }
  
  // Process withdrawal from wallet
  Future<String?> processWithdrawal({
    required String userId,
    required String userType,
    required double amount,
    required String paymentMethod,
    String? description,
  }) async {
    try {
      // Check if user has enough balance
      final walletDoc = await _firestoreService.getWallet(userId);
      if (walletDoc == null) {
        Get.snackbar('Error', 'Wallet not found');
        return null;
      }
      
      final wallet = WalletModel.fromFirestore(walletDoc);
      if (wallet.balance < amount) {
        Get.snackbar('Error', 'Insufficient balance');
        return null;
      }
      
      // Create pending transaction
      final transaction = TransactionModel(
        id: '',
        userId: userId,
        userType: userType,
        type: 'withdrawal',
        amount: amount,
        status: AppConstants.paymentPending,
        paymentMethod: paymentMethod,
        description: description ?? 'Wallet withdrawal',
        createdAt: DateTime.now(),
      );
      
      final transactionId = await _firestoreService.createTransaction(transaction);
      
      // Here you would integrate with actual payment provider (Stripe, PayPal, etc.)
      // This is a placeholder for the payment process
      
      // For demo purposes, we'll just mark the transaction as completed
      await _firestoreService.updateTransactionStatus(
        transactionId, 
        AppConstants.paymentCompleted,
        completedAt: DateTime.now(),
      );
      
      // Update wallet balance
      final updatedWallet = wallet.copyWith(
        balance: wallet.balance - amount,
        updatedAt: DateTime.now(),
      );
      
      await _firestoreService.updateWallet(updatedWallet);
      
      return transactionId;
    } catch (e) {
      Get.snackbar('Error', 'Failed to process withdrawal');
      return null;
    }
  }
  
  // Process payment for collaboration
  Future<String?> processCollaborationPayment({
    required String brandId,
    required String creatorId,
    required String campaignId,
    required String collaborationId,
    required double amount,
    required String paymentMethod,
  }) async {
    try {
      // Check if brand has enough balance
      final brandWalletDoc = await _firestoreService.getWallet(brandId);
      if (brandWalletDoc == null) {
        Get.snackbar('Error', 'Brand wallet not found');
        return null;
      }
      
      final brandWallet = WalletModel.fromFirestore(brandWalletDoc);
      if (brandWallet.balance < amount) {
        Get.snackbar('Error', 'Insufficient balance for payment');
        return null;
      }
      
      // Create payment transaction for brand (deduction)
      final brandTransaction = TransactionModel(
        id: '',
        userId: brandId,
        userType: AppConstants.userTypeBrand,
        type: 'payment',
        amount: amount,
        status: AppConstants.paymentCompleted,
        paymentMethod: 'wallet',
        campaignId: campaignId,
        collaborationId: collaborationId,
        description: 'Payment for collaboration',
        createdAt: DateTime.now(),
        completedAt: DateTime.now(),
      );
      
      await _firestoreService.createTransaction(brandTransaction);
      
      // Create payment transaction for creator (pending until work approved)
      final creatorTransaction = TransactionModel(
        id: '',
        userId: creatorId,
        userType: AppConstants.userTypeCreator,
        type: 'payment',
        amount: amount,
        status: AppConstants.paymentPending,
        paymentMethod: 'wallet',
        campaignId: campaignId,
        collaborationId: collaborationId,
        description: 'Payment for collaboration',
        createdAt: DateTime.now(),
      );
      
      final transactionId = await _firestoreService.createTransaction(creatorTransaction);
      
      // Update brand wallet (deduct immediately)
      final updatedBrandWallet = brandWallet.copyWith(
        balance: brandWallet.balance - amount,
        totalSpent: brandWallet.totalSpent + amount,
        updatedAt: DateTime.now(),
      );
      
      await _firestoreService.updateWallet(updatedBrandWallet);
      
      // Update creator wallet (add to pending balance)
      final creatorWalletDoc = await _firestoreService.getWallet(creatorId);
      if (creatorWalletDoc != null) {
        final creatorWallet = WalletModel.fromFirestore(creatorWalletDoc);
        final updatedCreatorWallet = creatorWallet.copyWith(
          pendingBalance: creatorWallet.pendingBalance + amount,
          updatedAt: DateTime.now(),
        );
        
        await _firestoreService.updateWallet(updatedCreatorWallet);
      }
      
      return transactionId;
    } catch (e) {
      Get.snackbar('Error', 'Failed to process collaboration payment');
      return null;
    }
  }
  
  // Release payment to creator after content approval
  Future<bool> releasePaymentToCreator({
    required String transactionId,
    required String creatorId,
  }) async {
    try {
      // Update transaction status
      await _firestoreService.updateTransactionStatus(
        transactionId, 
        AppConstants.paymentCompleted,
        completedAt: DateTime.now(),
      );
      
      // Get the transaction to get the amount
      final transactionDoc = await _firestoreService.transactions.doc(transactionId).get();
      if (!transactionDoc.exists) {
        return false;
      }
      
      final transactionData = transactionDoc.data() as Map<String, dynamic>;
      final amount = transactionData['amount']?.toDouble() ?? 0.0;
      
      // Update creator wallet
      final creatorWalletDoc = await _firestoreService.getWallet(creatorId);
      if (creatorWalletDoc != null) {
        final creatorWallet = WalletModel.fromFirestore(creatorWalletDoc);
        final updatedCreatorWallet = creatorWallet.copyWith(
          balance: creatorWallet.balance + amount,
          pendingBalance: creatorWallet.pendingBalance - amount,
          totalEarned: creatorWallet.totalEarned + amount,
          updatedAt: DateTime.now(),
        );
        
        await _firestoreService.updateWallet(updatedCreatorWallet);
      }
      
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to release payment');
      return false;
    }
  }
}