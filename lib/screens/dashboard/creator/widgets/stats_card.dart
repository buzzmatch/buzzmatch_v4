import 'package:flutter/material.dart';

class StatsCard extends StatelessWidget {
  final int collaborationsCount;
  final int completedCollaborationsCount;
  final double walletBalance;
  final double pendingBalance;

  const StatsCard({
    Key? key,
    required this.collaborationsCount,
    required this.completedCollaborationsCount,
    required this.walletBalance,
    required this.pendingBalance,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Collaborations: $collaborationsCount'),
            Text('Completed: $completedCollaborationsCount'),
            Text('Wallet Balance: \$${walletBalance.toStringAsFixed(2)}'),
            Text('Pending Balance: \$${pendingBalance.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }
} 