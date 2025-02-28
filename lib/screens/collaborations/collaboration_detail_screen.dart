import 'package:buzz_match/models/collaboration_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_styles.dart';
import '../../constants/app_constants.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/status_badge.dart';
import 'collaboration_detail_controller.dart';

class CollaborationDetailScreen extends StatelessWidget {
  const CollaborationDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CollaborationDetailController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          );
        }

        if (controller.collaboration.value == null ||
            controller.campaign.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Collaboration not found',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  label: 'Go Back',
                  onPressed: () => Get.back(),
                  fullWidth: false,
                ),
              ],
            ),
          );
        }

        final collaboration = controller.collaboration.value!;
        final campaign = controller.campaign.value!;
        final isBrand = controller.userType.value == AppConstants.userTypeBrand;

        return CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  campaign.campaignName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 3.0,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ],
                  ),
                ),
                background: campaign.referenceUrls.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: campaign.referenceUrls.first,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.primary.withOpacity(0.3),
                          child: const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.primary,
                          child: Center(
                            child: Text(
                              campaign.campaignName.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 56,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(
                        color: AppColors.primary,
                        child: Center(
                          child: Text(
                            campaign.campaignName.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 56,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
              ),
              actions: [
                IconButton(
                  onPressed: () => controller.openChat(),
                  icon: const Icon(Icons.message),
                  tooltip: 'Chat',
                ),
              ],
            ),

            // Collaboration content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status and parties
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Collaboration Status',
                                style: AppStyles.body2.copyWith(
                                  color: AppColors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              StatusBadge(
                                status: collaboration.status,
                                fontSize: 14,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
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
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: AppColors.primary.withOpacity(0.2),
                                backgroundImage: controller.otherPartyImage?.value != null
                                    ? NetworkImage(controller.otherPartyImage!.value!)
                                    : null,
                                child: controller.otherPartyImage?.value == null
                                    ? Text(
                                        controller.otherPartyName.value?.isNotEmpty == true
                                            ? controller.otherPartyName.value!.substring(0, 1)
                                            : '?',
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                              ),
                              SizedBox(width: 8),
                              Text(
                                controller.otherPartyName.value ?? '',
                                style: AppStyles.body2.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String value, IconData icon,
      {bool isSuccess = false}) {
    return Expanded(
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: AppColors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: AppStyles.caption.copyWith(
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppStyles.heading3.copyWith(
                color: isSuccess ? AppColors.success : AppColors.dark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTimeline(dynamic collaboration) {
    // Define all possible statuses in order
    final List<String> allStatuses = [
      AppConstants.statusMatched,
      AppConstants.statusContractSigned,
      AppConstants.statusProductShipped,
      AppConstants.statusContentInProgress,
      AppConstants.statusSubmitted,
      AppConstants.statusRevision,
      AppConstants.statusApproved,
      AppConstants.statusPaymentReleased,
      AppConstants.statusCompleted,
    ];

    // Get index of current status
    final int currentStatusIndex = allStatuses.indexOf(collaboration.status);

    // Format dates for display
    String formatDate(DateTime? date) {
      if (date == null) return 'Pending';
      return DateFormat('MMM dd, yyyy').format(date);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: allStatuses.length,
        itemBuilder: (context, index) {
          final status = allStatuses[index];
          final bool isCompleted = index <= currentStatusIndex;
          final bool isCurrent = index == currentStatusIndex;

          // Get date for status
          DateTime? statusDate;
          switch (status) {
            case AppConstants.statusContractSigned:
              statusDate = collaboration.contractSignedDate;
              break;
            case AppConstants.statusProductShipped:
              statusDate = collaboration.productShippedDate;
              break;
            case AppConstants.statusSubmitted:
              statusDate = collaboration.contentSubmittedDate;
              break;
            case AppConstants.statusApproved:
              statusDate = collaboration.approvedDate;
              break;
            case AppConstants.statusPaymentReleased:
              statusDate = collaboration.paymentReleasedDate;
              break;
            case AppConstants.statusCompleted:
              statusDate = collaboration.completedDate;
              break;
            default:
              statusDate = null;
          }

          return TimelineTile(
            alignment: TimelineAlign.manual,
            lineXY: 0.2,
            isFirst: index == 0,
            isLast: index == allStatuses.length - 1,
            indicatorStyle: IndicatorStyle(
              width: 20,
              height: 20,
              indicator: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? AppColors.primary : Colors.grey.shade300,
                ),
                child: isCurrent
                    ? const Center(
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 12,
                        ),
                      )
                    : isCompleted
                        ? const Center(
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 12,
                            ),
                          )
                        : null,
              ),
            ),
            beforeLineStyle: LineStyle(
              color: isCompleted ? AppColors.primary : Colors.grey.shade300,
            ),
            afterLineStyle: LineStyle(
              color: index < currentStatusIndex
                  ? AppColors.primary
                  : Colors.grey.shade300,
            ),
            endChild: Container(
              padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status,
                    style: AppStyles.body2.copyWith(
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      color: isCurrent ? AppColors.primary : AppColors.dark,
                    ),
                  ),
                  if (isCompleted && statusDate != null)
                    Text(
                      formatDate(statusDate),
                      style: AppStyles.caption.copyWith(
                        color: AppColors.grey,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  Widget _buildNextActionSection(
    CollaborationModel collaboration,
    bool isBrand,
    CollaborationDetailController controller,
  ) {
    // Determine next action based on status and user type
    String actionTitle = 'Next Action';
    String actionDescription = '';
    Widget actionButton = const SizedBox.shrink();

    switch (collaboration.status) {
      case AppConstants.statusMatched:
        if (isBrand) {
          actionDescription = 'Wait for the creator to sign the contract';
          actionButton = CustomButton(
            label: 'Remind Creator',
            onPressed: () => controller.remindCreator(),
            color: AppColors.warning,
          );
        } else {
          actionDescription = 'Review and sign the contract to proceed';
          actionButton = CustomButton(
            label: 'Sign Contract',
            onPressed: () => controller.signContract(),
          );
        }
        break;

      case AppConstants.statusContractSigned:
        if (isBrand) {
          actionDescription = 'Ship the product to the creator';
          actionButton = CustomButton(
            label: 'Mark as Shipped',
            onPressed: () => controller.markAsShipped(),
          );
        } else {
          actionDescription = 'Waiting for the brand to ship the product';
          actionButton = CustomButton(
            label: 'Contact Brand',
            onPressed: () => controller.openChat(),
            isOutlined: true,
          );
        }
        break;

      case AppConstants.statusProductShipped:
        if (isBrand) {
          actionDescription = 'Waiting for the creator to create content';
          actionButton = CustomButton(
            label: 'Contact Creator',
            onPressed: () => controller.openChat(),
            isOutlined: true,
          );
        } else {
          actionDescription = 'Create content based on the campaign requirements';
          actionButton = CustomButton(
            label: 'Submit Content',
            onPressed: () => controller.uploadContent(),
          );
        }
        break;

      case AppConstants.statusContentInProgress:
        if (isBrand) {
          actionDescription = 'Waiting for the creator to submit content';
          actionButton = CustomButton(
            label: 'Contact Creator',
            onPressed: () => controller.openChat(),
            isOutlined: true,
          );
        } else {
          actionDescription = 'Continue creating content based on requirements';
          actionButton = CustomButton(
            label: 'Submit Content',
            onPressed: () => controller.uploadContent(),
          );
        }
        break;

      case AppConstants.statusSubmitted:
        if (isBrand) {
          actionDescription = 'Review the submitted content';
          actionButton = Row(
            children: [
              Expanded(
                child: CustomButton(
                  label: 'Request Revisions',
                  onPressed: () => controller.requestRevisions(),
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  label: 'Approve',
                  onPressed: () => controller.approveContent(),
                  color: AppColors.success,
                ),
              ),
            ],
          );
        } else {
          actionDescription = 'Waiting for the brand to review your submission';
          actionButton = CustomButton(
            label: 'Contact Brand',
            onPressed: () => controller.openChat(),
            isOutlined: true,
          );
        }
        break;

      case AppConstants.statusRevision:
        if (isBrand) {
          actionDescription = 'Waiting for the creator to apply revisions';
          actionButton = CustomButton(
            label: 'Contact Creator',
            onPressed: () => controller.openChat(),
            isOutlined: true,
          );
        } else {
          actionDescription = 'Apply the requested revisions and resubmit';
          actionButton = CustomButton(
            label: 'Submit Revised Content',
            onPressed: () => controller.uploadContent(),
          );
        }
        break;

      case AppConstants.statusApproved:
        if (isBrand) {
          actionDescription = 'Release payment to the creator';
          actionButton = CustomButton(
            label: 'Release Payment',
            onPressed: () => controller.releasePayment(),
          );
        } else {
          actionDescription = 'Waiting for the brand to release payment';
          actionButton = CustomButton(
            label: 'Contact Brand',
            onPressed: () => controller.openChat(),
            isOutlined: true,
          );
        }
        break;

      case AppConstants.statusPaymentReleased:
        actionDescription = 'Collaboration completed successfully!';
        actionButton = CustomButton(
          label: 'Mark as Completed',
          onPressed: () => controller.markAsCompleted(),
          color: AppColors.success,
        );
        break;

      case AppConstants.statusCompleted:
        actionDescription = 'This collaboration has been completed.';
        actionButton = CustomButton(
          label: 'Start New Collaboration',
          onPressed: () => Get.back(),
          isOutlined: true,
        );
        break;

      default:
        actionDescription = 'No action required at this time.';
    }

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            actionTitle,
            style: AppStyles.heading3,
          ),
          const SizedBox(height: 8),
          Text(
            actionDescription,
            style: AppStyles.body1,
          ),
          const SizedBox(height: 16),
          actionButton,
        ],
      ),
    );
  }
}