import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/collaboration_model.dart';
import '../../models/campaign_model.dart';
import '../../models/brand_model.dart';
import '../../models/creator_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';
import '../../services/payment_service.dart';
import '../../services/chat_service.dart';
import '../../constants/app_constants.dart';
import '../../routes/app_pages.dart';

class CollaborationDetailController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final StorageService _storageService = Get.find<StorageService>();
  final PaymentService _paymentService = Get.find<PaymentService>();
  final ChatService _chatService = Get.find<ChatService>();
  
  // Observable variables
  final RxBool isLoading = true.obs;
  final Rx<CollaborationModel?> collaboration = Rx<CollaborationModel?>(null);
  final Rx<CampaignModel?> campaign = Rx<CampaignModel?>(null);
  final RxString userType = ''.obs;
  
  // Information about the other party
  final RxString otherPartyName = ''.obs;
  final RxString otherPartyId = ''.obs;
  final RxString? otherPartyImage = RxString('');
  
  // Chat ID
  String? chatId;
  
  @override
  void onInit() {
    super.onInit();
    
    // Determine user type
    userType.value = _authService.currentUser.value?.userType ?? '';
    
    // Get collaboration ID from arguments
    final Map<String, dynamic> args = Get.arguments ?? {};
    final String collaborationId = args['collaborationId'] ?? '';
    
    if (collaborationId.isNotEmpty) {
      loadCollaboration(collaborationId);
    } else {
      isLoading.value = false;
    }
  }
  
  Future<void> loadCollaboration(String collaborationId) async {
    try {
      isLoading.value = true;
      
      // Get collaboration
      final collaborationDoc = await _firestoreService.getCollaboration(collaborationId);
      if (collaborationDoc != null) {
        collaboration.value = CollaborationModel.fromFirestore(collaborationDoc);
        
        // Get associated campaign
        final campaignDoc = await _firestoreService.getCampaign(collaboration.value!.campaignId);
        if (campaignDoc != null) {
          campaign.value = CampaignModel.fromFirestore(campaignDoc);
        }
        
        // Get chat for this collaboration
        final chatDoc = await _firestoreService.getChatByCollaboration(collaborationId);
        if (chatDoc != null) {
          chatId = chatDoc.id;
        }
        
        // Determine other party based on user type
        if (userType.value == AppConstants.userTypeBrand) {
          // Current user is brand, other party is creator
          otherPartyId.value = collaboration.value!.creatorId;
          
          // Get creator details
          final creatorDoc = await _firestoreService.getCreator(otherPartyId.value);
          if (creatorDoc != null) {
            final creator = CreatorModel.fromFirestore(creatorDoc);
            otherPartyName.value = creator.fullName ?? '';
            otherPartyImage!.value = creator.profileImage ?? '';
          }
        } else {
          // Current user is creator, other party is brand
          otherPartyId.value = collaboration.value?.brandId ?? '';
          
          // Get brand details
          final brandDoc = await _firestoreService.getBrand(otherPartyId.value);
          if (brandDoc != null) {
            final brand = BrandModel.fromFirestore(brandDoc);
            otherPartyName.value = brand.companyName ?? '';
            otherPartyImage!.value = brand.logoUrl ?? '';
          }
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load collaboration: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Status transition methods
  Future<void> signContract() async {
    if (collaboration.value == null) return;
    
    try {
      // TODO: In a real app, this would involve a proper digital signature process
      // For demonstration purposes, we'll just update the status
      
      final updatedCollaboration = collaboration.value!.copyWith(
        status: AppConstants.statusContractSigned,
        contractSignedDate: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _firestoreService.updateCollaboration(updatedCollaboration);
      
      // Reload collaboration
      await loadCollaboration(collaboration.value!.id);
      
      Get.snackbar(
        'Success',
        'Product marked as shipped',
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to update status: ${e.toString()}');
    }
  }
  
  Future<void> uploadContent() async {
    if (collaboration.value == null) return;
    
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();
      
      if (images.isEmpty) return;
      
      // Show loading dialog
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );
      
      // Upload images
      List<String> contentUrls = [...collaboration.value!.contentUrls];
      
      for (var image in images) {
        final File file = File(image.path);
        final url = await _storageService.uploadCollaborationContent(
          file,
          collaboration.value!.id,
        );
        
        if (url != null) {
          contentUrls.add(url);
        }
      }
      
      // Update collaboration status based on current status
      String newStatus;
      DateTime? contentSubmittedDate;
      
      if (collaboration.value!.status == AppConstants.statusProductShipped ||
          collaboration.value!.status == AppConstants.statusContentInProgress) {
        newStatus = AppConstants.statusSubmitted;
        contentSubmittedDate = DateTime.now();
      } else if (collaboration.value!.status == AppConstants.statusRevision) {
        newStatus = AppConstants.statusSubmitted;
        // Keep existing submission date
        contentSubmittedDate = collaboration.value!.contentSubmittedDate;
      } else {
        newStatus = collaboration.value!.status;
        contentSubmittedDate = collaboration.value!.contentSubmittedDate;
      }
      
      final updatedCollaboration = collaboration.value!.copyWith(
        status: newStatus,
        contentUrls: contentUrls,
        contentSubmittedDate: contentSubmittedDate,
        updatedAt: DateTime.now(),
      );
      
      await _firestoreService.updateCollaboration(updatedCollaboration);
      
      // Close loading dialog
      Get.back();
      
      // Reload collaboration
      await loadCollaboration(collaboration.value!.id);
      
      Get.snackbar(
        'Success',
        'Content uploaded successfully',
      );
    } catch (e) {
      // Close loading dialog
      Get.back();
      Get.snackbar('Error', 'Failed to upload content: ${e.toString()}');
    }
  }
  
  Future<void> requestRevisions() async {
    if (collaboration.value == null) return;
    
    // Show dialog to enter feedback
    final TextEditingController feedbackController = TextEditingController();
    
    final bool? result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Request Revisions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide feedback for the creator:'),
            const SizedBox(height: 16),
            TextField(
              controller: feedbackController,
              decoration: const InputDecoration(
                hintText: 'Enter your feedback here',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    
    if (result != true || feedbackController.text.isEmpty) return;
    
    try {
      // Add feedback note
      List<String> feedbackNotes = [...collaboration.value!.feedbackNotes];
      feedbackNotes.add(feedbackController.text);
      
      // Update collaboration
      final updatedCollaboration = collaboration.value!.copyWith(
        status: AppConstants.statusRevision,
        feedbackNotes: feedbackNotes,
        updatedAt: DateTime.now(),
      );
      
      await _firestoreService.updateCollaboration(updatedCollaboration);
      
      // Reload collaboration
      await loadCollaboration(collaboration.value!.id);
      
      Get.snackbar(
        'Success',
        'Revision requested successfully',
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to request revisions: ${e.toString()}');
    }
  }
  
  Future<void> approveContent() async {
    if (collaboration.value == null) return;
    
    try {
      final updatedCollaboration = collaboration.value!.copyWith(
        status: AppConstants.statusApproved,
        approvedDate: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _firestoreService.updateCollaboration(updatedCollaboration);
      
      // Reload collaboration
      await loadCollaboration(collaboration.value!.id);
      
      Get.snackbar(
        'Success',
        'Content approved successfully',
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to approve content: ${e.toString()}');
    }
  }
  
  Future<void> releasePayment() async {
    if (collaboration.value == null) return;
    
    try {
      // In a real app, this would involve a proper payment process
      // For demonstration purposes, we'll just update the status
      
      // Get pending transaction for this collaboration
      // (In a real app this would be handled by the payment service)
      final transactionDocs = await _firestoreService.transactions
          .where('collaborationId', isEqualTo: collaboration.value!.id)
          .where('status', isEqualTo: AppConstants.paymentPending)
          .get();
      
      if (transactionDocs.docs.isNotEmpty) {
        final transactionId = transactionDocs.docs.first.id;
        
        // Release payment
        final result = await _paymentService.releasePaymentToCreator(
          transactionId: transactionId,
          creatorId: collaboration.value!.creatorId,
        );
        
        if (result) {
          // Update collaboration
          final updatedCollaboration = collaboration.value!.copyWith(
            status: AppConstants.statusPaymentReleased,
            paymentReleasedDate: DateTime.now(),
            isPaid: true,
            updatedAt: DateTime.now(),
          );
          
          await _firestoreService.updateCollaboration(updatedCollaboration);
          
          // Reload collaboration
          await loadCollaboration(collaboration.value!.id);
          
          Get.snackbar(
            'Success',
            'Payment released successfully',
          );
        } else {
          throw Exception('Failed to release payment');
        }
      } else {
        // No pending transaction found, create one
        final brandId = collaboration.value!.brandId;
        final creatorId = collaboration.value!.creatorId;
        
        // Process payment
        await _paymentService.processCollaborationPayment(
          brandId: brandId,
          creatorId: creatorId,
          campaignId: collaboration.value!.campaignId,
          collaborationId: collaboration.value!.id,
          amount: collaboration.value!.budget,
          paymentMethod: 'wallet',
        );
        
        // Update collaboration
        final updatedCollaboration = collaboration.value!.copyWith(
          status: AppConstants.statusPaymentReleased,
          paymentReleasedDate: DateTime.now(),
          isPaid: true,
          updatedAt: DateTime.now(),
        );
        
        await _firestoreService.updateCollaboration(updatedCollaboration);
        
        // Reload collaboration
        await loadCollaboration(collaboration.value!.id);
        
        Get.snackbar(
          'Success',
          'Payment released successfully',
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to release payment: ${e.toString()}');
    }
  }
  
  Future<void> markAsCompleted() async {
    if (collaboration.value == null) return;
    
    try {
      final updatedCollaboration = collaboration.value!.copyWith(
        status: AppConstants.statusCompleted,
        completedDate: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _firestoreService.updateCollaboration(updatedCollaboration);
      
      // Reload collaboration
      await loadCollaboration(collaboration.value!.id);
      
      Get.snackbar(
        'Success',
        'Collaboration marked as completed',
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to update status: ${e.toString()}');
    }
  }
  
  void openChat() {
    if (chatId != null) {
      Get.toNamed(
        '/chat-detail',
        arguments: {'chatId': chatId},
      );
    } else if (collaboration.value != null) {
      // Chat doesn't exist yet, create one
      _createChat();
    }
  }
  
  Future<void> _createChat() async {
    if (collaboration.value == null) return;
    
    try {
      chatId = await _chatService.createChat(
        campaignId: collaboration.value!.campaignId,
        collaborationId: collaboration.value!.id,
        brandId: collaboration.value!.brandId,
        creatorId: collaboration.value!.creatorId,
      );
      
      if (chatId != null) {
        Get.toNamed(
          '/chat-detail',
          arguments: {'chatId': chatId},
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to create chat: ${e.toString()}');
    }
  }
  
  Future<void> remindCreator() async {
    // Send reminder message via chat
    openChat();
  }
  
  void viewContent(String url) {
    // Navigate to content viewer
    Get.toNamed(
      '/content-viewer',
      arguments: {'url': url},
    );
  }
  
  void viewContract() {
    if (collaboration.value?.contract == null) return;
    
    // Navigate to contract viewer
    Get.toNamed(
      '/contract-viewer',
      arguments: {'url': collaboration.value!.contract},
    );
  }

  Widget markAsShipped() {
    // Implementation for markAsShipped
    return Container(); // Placeholder widget to satisfy the return type
  }
}