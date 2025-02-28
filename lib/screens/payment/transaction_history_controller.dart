// ignore_for_file: await_only_futures

import 'package:buzz_match/constants/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../constants/app_constants.dart';
import 'transaction_history_screen.dart';


class TransactionHistoryController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirestoreService _firestoreService = Get.find<FirestoreService>();

  // Controllers
  final TextEditingController searchController = TextEditingController();

  // Observable variables
  final RxBool isLoading = true.obs;
  final RxString userType = ''.obs;
  final RxString userId = ''.obs;
  final RxList<Map<String, dynamic>> allTransactions = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredTransactions = <Map<String, dynamic>>[].obs;

  // Filters
  final Rx<DateTime?> startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);
  final RxString dateRangeText = ''.obs;

  @override
  void onInit() {
    super.onInit();
    userType.value = _authService.currentUser.value?.userType ?? '';

    if (userType.value == AppConstants.userTypeBrand) {
      userId.value = _authService.currentBrand.value?.id ?? '';
    } else {
      userId.value = _authService.currentCreator.value?.id ?? '';
    }

    if (userId.value.isNotEmpty) {
      loadTransactions();
    } else {
      isLoading.value = false;
    }

    searchController.addListener(filterTransactions);
  }

  Future<void> loadTransactions() async {
    try {
      isLoading.value = true;

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
          'date': data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : DateTime.now(),
          'description': data['description'] ?? '',
        });
      }

      transactions.sort((a, b) => b['date'].compareTo(a['date']));

      allTransactions.value = transactions;
      filteredTransactions.value = List.from(transactions);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load transactions: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void filterTransactions() {
    final searchTerm = searchController.text.toLowerCase();

    filteredTransactions.value = allTransactions.where((transaction) {
      if (searchTerm.isNotEmpty) {
        return transaction['description'] != null &&
            transaction['description'].toString().toLowerCase().contains(searchTerm);
      }
      return true;
    }).toList();
  }

  void showDateRangePickerDialog(BuildContext context) {
    showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        start: startDate.value ?? DateTime.now().subtract(const Duration(days: 30)),
        end: endDate.value ?? DateTime.now(),
      ),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppColors.primary,
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
  }
}