import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_styles.dart';
import '../../constants/app_constants.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import 'campaign_create_controller.dart';

class CampaignCreateScreen extends StatelessWidget {
  const CampaignCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CampaignCreateController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Obx(() => Text(controller.isEditing.value
            ? 'Edit Campaign'
            : 'Create Campaign')),
        actions: [
          if (controller.isEditing.value)
            IconButton(
              onPressed: () => controller.toggleActive(),
              icon: Obx(() => Icon(
                    controller.isActive.value
                        ? Icons.toggle_on
                        : Icons.toggle_off,
                    color: controller.isActive.value
                        ? AppColors.primary
                        : AppColors.grey,
                    size: 28,
                  )),
              tooltip: 'Toggle Campaign Status',
            ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Campaign name
                CustomTextField(
                  label: 'Campaign Name',
                  hint: 'Enter campaign name',
                  controller: controller.campaignNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campaign name is required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Product name
                CustomTextField(
                  label: 'Product / Event Name',
                  hint: 'Enter product or event name',
                  controller: controller.productNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Product name is required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Required content types
                Text(
                  'Required Content Types',
                  style: AppStyles.body2.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: MultiSelectBottomSheetField(
                    initialChildSize: 0.4,
                    listType: MultiSelectListType.CHIP,
                    searchable: true,
                    buttonText: const Text('Select Content Types'),
                    title: const Text('Content Types'),
                    items: AppConstants.contentTypes
                        .map((type) => MultiSelectItem<String>(type, type))
                        .toList(),
                    validator: (values) {
                      if (values == null || values.isEmpty) {
                        return 'Please select at least one content type';
                      }
                      return null;
                    },
                    initialValue: controller.selectedContentTypes,
                    onConfirm: (values) {
                      controller.selectedContentTypes = values.cast<String>();
                    },
                    chipDisplay: MultiSelectChipDisplay(
                      onTap: (item) {
                        controller.selectedContentTypes.remove(item);
                        return controller.selectedContentTypes;
                      },
                      chipColor: AppColors.primary.withOpacity(0.1),
                      textStyle: const TextStyle(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Budget
                CustomTextField(
                  label: 'Budget (${AppConstants.currency})',
                  hint: 'Enter campaign budget',
                  controller: controller.budgetController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Budget is required';
                    }
                    if (double.tryParse(value) == null || double.parse(value) <= 0) {
                      return 'Please enter a valid budget';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Deadline
                CustomTextField(
                  label: 'Deadline',
                  hint: 'Select deadline',
                  controller: controller.deadlineController,
                  readOnly: true,
                  onTap: () => controller.selectDeadline(context),
                  suffix: const Icon(Icons.calendar_today),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Deadline is required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Description
                CustomTextField(
                  label: 'Description',
                  hint: 'Enter campaign description',
                  controller: controller.descriptionController,
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Description is required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Reference images
                Text(
                  'Reference Images',
                  style: AppStyles.body2.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Selected images
                      Obx(() {
                        if (controller.referenceImages.isEmpty &&
                            controller.existingReferenceUrls.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            alignment: Alignment.center,
                            child: Text(
                              'No reference images selected',
                              style: AppStyles.body2.copyWith(
                                color: AppColors.grey,
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: [
                            // Existing images from URL
                            if (controller.existingReferenceUrls.isNotEmpty)
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: controller.existingReferenceUrls
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  final index = entry.key;
                                  final url = entry.value;
                                  return Stack(
                                    children: [
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          image: DecorationImage(
                                            image: NetworkImage(url),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: GestureDetector(
                                          onTap: () => controller.removeExistingReference(index),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),

                            // New selected images
                            if (controller.referenceImages.isNotEmpty) ...[
                              if (controller.existingReferenceUrls.isNotEmpty)
                                const SizedBox(height: 16),

                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: controller.referenceImages
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  final index = entry.key;
                                  final file = entry.value;
                                  return Stack(
                                    children: [
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          image: DecorationImage(
                                            image: FileImage(file),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: GestureDetector(
                                          onTap: () => controller.removeReferenceImage(index),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ],
                          ],
                        );
                      }),

                      const SizedBox(height: 16),

                      // Upload button
                      CustomButton(
                        label: 'Add Reference Images',
                        onPressed: () => controller.pickReferenceImages(),
                        icon: Icons.image,
                        isOutlined: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Submit button
                CustomButton(
                  label: controller.isEditing.value ? 'Update Campaign' : 'Create Campaign',
                  onPressed: () => controller.saveCampaign(),
                  isLoading: controller.isSaving.value,
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      }),
    );
  }
}