import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;
  
  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize = 12.0,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _getStatusColor(),
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
  
  Color _getStatusColor() {
    switch (status) {
      case AppConstants.statusMatched:
        return Colors.blue;
      case AppConstants.statusContractSigned:
        return Colors.indigo;
      case AppConstants.statusProductShipped:
        return Colors.purple;
      case AppConstants.statusContentInProgress:
        return Colors.orange;
      case AppConstants.statusSubmitted:
        return Colors.cyan;
      case AppConstants.statusRevision:
        return Colors.amber;
      case AppConstants.statusApproved:
        return Colors.teal;
      case AppConstants.statusPaymentReleased:
        return Colors.green;
      case AppConstants.statusCompleted:
        return AppColors.success;
      case AppConstants.paymentPending:
        return Colors.amber;
      case AppConstants.paymentFailed:
        return AppColors.error;
      case AppConstants.paymentRefunded:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}