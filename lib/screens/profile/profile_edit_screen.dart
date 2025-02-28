import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_styles.dart';
import '../../constants/app_constants.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import 'profile_edit_controller.dart';

class ProfileEditScreen extends StatelessWidget {
  const ProfileEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileEditController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Image
                Align(
                  alignment: Alignment.center,
                  child: Stack(
                    children: [
                      // Image
                      Obx(() {
                        if (controller.imageFile.value != null) {
                          return CircleAvatar(
                            radius: 60,
                            backgroundImage: FileImage(controller.imageFile.value!),
                          );
                        } else if (controller.userType.value == AppConstants.userTypeBrand) {
                          // Brand logo
                          return CircleAvatar(
                            radius: 60,
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            backgroundImage: controller.brand.value?.logoUrl != null
                                ? CachedNetworkImageProvider(controller.brand.value!.logoUrl!)
                                : null,
                            child: controller.brand.value?.logoUrl == null
                                ? Text(
                                    controller.brand.value?.companyName.substring(0, 1).toUpperCase() ?? 'B',
                                    style: const TextStyle(
                                      fontSize: 60,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  )
                                : null,
                          );
                        } else {
                          // Creator profile image
                          return CircleAvatar(
                            radius: 60,
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            backgroundImage: controller.creator.value?.profileImage != null
                                ? CachedNetworkImageProvider(controller.creator.value!.profileImage!)
                                : null,
                            child: controller.creator.value?.profileImage == null
                                ? Text(
                                    controller.creator.value?.fullName.substring(0, 1).toUpperCase() ?? 'C',
                                    style: const TextStyle(
                                      fontSize: 60,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  )
                                : null,
                          );
                        }
                      }),
                      
                      // Edit button
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => controller.pickImage(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Brand-specific form
                if (controller.userType.value == AppConstants.userTypeBrand)
                  _buildBrandForm(context, controller),
                
                // Creator-specific form
                if (controller.userType.value == AppConstants.userTypeCreator)
                  _buildCreatorForm(context, controller),
                
                const SizedBox(height: 32),
                
                // Save button
                CustomButton(
                  label: 'Save Changes',
                  onPressed: () => controller.saveChanges(),
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
  
  Widget _buildBrandForm(BuildContext context, ProfileEditController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Company Name
        CustomTextField(
          label: 'Company Name',
          hint: 'Enter company name',
          controller: controller.companyNameController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Company name is required';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Business Category dropdown
        CustomTextField(
          label: 'Business Category',
          hint: 'Select business category',
          controller: controller.businessCategoryController,
          readOnly: true,
          suffix: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  controller.businessCategoryController.text = newValue;
                }
              },
              items: AppConstants.businessCategories
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Business category is required';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Email
        CustomTextField(
          label: 'Email',
          hint: 'Enter email address',
          controller: controller.emailController,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Email is required';
            }
            if (!GetUtils.isEmail(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Phone
        CustomTextField(
          label: 'Phone',
          hint: 'Enter phone number',
          controller: controller.phoneController,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Phone number is required';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Country
        CustomTextField(
          label: 'Country',
          hint: 'Enter country',
          controller: controller.countryController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Country is required';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Website (optional)
        CustomTextField(
          label: 'Website (Optional)',
          hint: 'Enter website URL',
          controller: controller.websiteController,
          keyboardType: TextInputType.url,
        ),
        
        const SizedBox(height: 16),
        
        // Description (optional)
        CustomTextField(
          label: 'Description (Optional)',
          hint: 'Tell about your brand...',
          controller: controller.descriptionController,
          maxLines: 5,
        ),
        
        const SizedBox(height: 16),
        
        // Social Links
        Text(
          'Social Media Links (Optional)',
          style: AppStyles.body2.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        
        // Existing social links
        Obx(() => ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.socialLinks.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(text: controller.socialLinks[index]),
                      onChanged: (value) => controller.updateSocialLink(index, value),
                      decoration: InputDecoration(
                        hintText: 'Enter social media link',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.link),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => controller.removeSocialLink(index),
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
                ],
              ),
            );
          },
        )),
        
        // Add social link button
        TextButton.icon(
          onPressed: () => controller.addSocialLink(),
          icon: const Icon(Icons.add),
          label: const Text('Add Social Link'),
        ),
      ],
    );
  }
  
  Widget _buildCreatorForm(BuildContext context, ProfileEditController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Full Name
        CustomTextField(
          label: 'Full Name',
          hint: 'Enter your full name',
          controller: controller.fullNameController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Full name is required';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Content Type dropdown
        CustomTextField(
          label: 'Content Type',
          hint: 'Select content type',
          controller: controller.contentTypeController,
          readOnly: true,
          suffix: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  controller.contentTypeController.text = newValue;
                }
              },
              items: AppConstants.contentTypes
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Content type is required';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Main Category dropdown
        CustomTextField(
          label: 'Main Category',
          hint: 'Select main category',
          controller: controller.mainCategoryController,
          readOnly: true,
          suffix: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  controller.mainCategoryController.text = newValue;
                }
              },
              items: AppConstants.creatorCategories
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Main category is required';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Email
        CustomTextField(
          label: 'Email',
          hint: 'Enter email address',
          controller: controller.emailController,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Email is required';
            }
            if (!GetUtils.isEmail(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Phone
        CustomTextField(
          label: 'Phone',
          hint: 'Enter phone number',
          controller: controller.phoneController,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Phone number is required';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Country
        CustomTextField(
          label: 'Country',
          hint: 'Enter country',
          controller: controller.countryController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Country is required';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Bio (optional)
        CustomTextField(
          label: 'Bio (Optional)',
          hint: 'Tell about yourself...',
          controller: controller.bioController,
          maxLines: 5,
        ),
        
        const SizedBox(height: 24),
        
        // Portfolio
        const Text(
          'Portfolio',
          style: AppStyles.heading3,
        ),
        const SizedBox(height: 8),
        
        // Existing portfolio items
        Obx(() {
          if (controller.portfolioUrls.isEmpty && controller.portfolioFiles.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.image,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No portfolio items yet',
                    style: AppStyles.body1.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }
          
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: controller.portfolioUrls.length + controller.portfolioFiles.length,
            itemBuilder: (context, index) {
              if (index < controller.portfolioUrls.length) {
                // Existing image from URL
                return Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(controller.portfolioUrls[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => controller.removePortfolioUrl(index),
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
              } else {
                // New image from file
                final fileIndex = index - controller.portfolioUrls.length;
                return Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(controller.portfolioFiles[fileIndex]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => controller.removePortfolioFile(fileIndex),
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
              }
            },
          );
        }),
        
        const SizedBox(height: 16),
        
        // Add portfolio item button
        CustomButton(
          label: 'Add Portfolio Item',
          onPressed: () => controller.pickPortfolioImage(),
          icon: Icons.add_photo_alternate,
          isOutlined: true,
        ),
        
        const SizedBox(height: 24),
        
        // Social Links
        Text(
          'Social Media Links (Optional)',
          style: AppStyles.body2.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        
        // Existing social links
        Obx(() => ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.socialLinks.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(text: controller.socialLinks[index]),
                      onChanged: (value) => controller.updateSocialLink(index, value),
                      decoration: InputDecoration(
                        hintText: 'Enter social media link',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.link),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => controller.removeSocialLink(index),
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
                ],
              ),
            );
          },
        )),
        
        // Add social link button
        TextButton.icon(
          onPressed: () => controller.addSocialLink(),
          icon: const Icon(Icons.add),
          label: const Text('Add Social Link'),
        ),
      ],
    );
  }
}