import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../constants/app_colors.dart';
import 'transaction_history_controller.dart';
import 'transaction_history_controller.dart';


class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TransactionHistoryController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Transaction History'),
        actions: [
          IconButton(
            onPressed: () => controller.showDateRangePickerDialog(context),
            icon: const Icon(Icons.date_range),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: controller.searchController,
              decoration: InputDecoration(
                hintText: 'Search transactions...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.filteredTransactions.isEmpty) {
                return const Center(child: Text('No transactions found'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.filteredTransactions.length,
                itemBuilder: (context, index) {
                  final transaction = controller.filteredTransactions[index];
                  return ListTile(
                    title: Text(transaction['description'] ?? 'Transaction'),
                    subtitle: Text(DateFormat.yMMMd().format(transaction['date'])),
                    trailing: Text('${transaction['amount']}'),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
