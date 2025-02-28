import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/chat_models.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';
import '../../services/chat_service.dart';
import '../../constants/app_constants.dart';
import '../../routes/app_pages.dart';

class ChatDetailController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final StorageService _storageService = Get.find<StorageService>();
  final ChatService _chatService = Get.find<ChatService>();
  
  // Controllers
  final TextEditingController messageController = TextEditingController();
  final FocusNode messageFocus = FocusNode();
  
  // Observable variables
  final RxBool isLoading = true.obs;
  final RxString userType = ''.obs;
  final RxString currentUserId = ''.obs;
  final RxString chatId = ''.obs;
  final RxList<MessageModel> messages = <MessageModel>[].obs;
  
  // Other party info
  final RxString otherPartyName = ''.obs;
  final RxString otherPartyId = ''.obs;
  final RxString otherPartyImage = RxString('');
  
  // Collaboration ID (if available)
  final RxString collaborationId = ''.obs;
  
  // Stream subscription
  late Stream<QuerySnapshot> messagesStream;
  
  @override
  void onInit() {
    super.onInit();
    
    // Determine user type and ID
    userType.value = _authService.currentUser.value?.userType ?? '';
    
    if (userType.value == AppConstants.userTypeBrand) {
      currentUserId.value = _authService.currentBrand.value?.id ?? '';
    } else {
      currentUserId.value = _authService.currentCreator.value?.id ?? '';
    }
    
    // Get chat ID from arguments
    final Map<String, dynamic> args = Get.arguments ?? {};
    chatId.value = args['chatId'] ?? '';
    
    if (chatId.value.isNotEmpty && currentUserId.value.isNotEmpty) {
      // Load chat data
      loadChatData();
      
      // Set up stream listener
      setupMessagesStream();
      
      // Mark messages as read
      _firestoreService.markMessagesAsRead(chatId.value, currentUserId.value);
    } else {
      isLoading.value = false;
    }
  }
  
  @override
  void onClose() {
    messageController.dispose();
    messageFocus.dispose();
    super.onClose();
  }
  
  Future<void> loadChatData() async {
    try {
      // Get chat details
      final chatDoc = await _firestoreService.getChat(chatId.value);
      if (chatDoc == null) {
        return;
      }
      
      final chatData = chatDoc.data() as Map<String, dynamic>;
      
      // Set collaboration ID if available
      collaborationId.value = chatData['collaborationId'] ?? '';
      
      // Determine other party based on user type
      if (userType.value == AppConstants.userTypeBrand) {
        // Current user is brand, other party is creator
        otherPartyId.value = chatData['creatorId'] ?? '';
        
        // Get creator details
        final creatorDoc = await _firestoreService.getCreator(otherPartyId.value);
        if (creatorDoc != null) {
          final creatorData = creatorDoc.data() as Map<String, dynamic>;
          otherPartyName.value = creatorData['fullName'] ?? 'Creator';
          otherPartyImage.value = creatorData['profileImage'];
        }
      } else {
        // Current user is creator, other party is brand
        otherPartyId.value = chatData['brandId'] ?? '';
        
        // Get brand details
        final brandDoc = await _firestoreService.getBrand(otherPartyId.value);
        if (brandDoc != null) {
          final brandData = brandDoc.data() as Map<String, dynamic>;
          otherPartyName.value = brandData['companyName'] ?? 'Brand';
          otherPartyImage.value = brandData['logoUrl'];
        }
      }
    } catch (e) {
      print('Error loading chat data: $e');
    }
  }
  
  void setupMessagesStream() {
    messagesStream = _firestoreService.messages
        .where('chatId', isEqualTo: chatId.value)
        .orderBy('createdAt', descending: true)
        .snapshots();
    
    // Listen to the stream
    messagesStream.listen((snapshot) {
      final List<MessageModel> messagesList = snapshot.docs
          .map((doc) => MessageModel.fromFirestore(doc))
          .toList();
      
      messages.value = messagesList;
      isLoading.value = false;
      
      // Mark messages as read
      _firestoreService.markMessagesAsRead(chatId.value, currentUserId.value);
    }, onError: (error) {
      print('Error listening to messages: $error');
      isLoading.value = false;
    });
  }
  
  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;
    
    // Clear text field
    messageController.clear();
    
    try {
      await _chatService.sendTextMessage(
        chatId: chatId.value,
        senderId: currentUserId.value,
        senderType: userType.value,
        message: text,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to send message: ${e.toString()}');
    }
  }
  
  Future<void> pickAttachment() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image == null) return;
      
      final File file = File(image.path);
      
      // Show dialog for message text
      final TextEditingController captionController = TextEditingController();
      
      final bool? result = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Add Caption'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: FileImage(file),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: captionController,
                decoration: const InputDecoration(
                  hintText: 'Add a caption (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
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
              child: const Text('Send'),
            ),
          ],
        ),
      );
      
      if (result != true) return;
      
      // Upload and send message with attachment
      final String? attachmentUrl = await _storageService.uploadChatAttachment(
        file,
        chatId.value,
      );
      
      if (attachmentUrl != null) {
        await _chatService.sendMessageWithAttachment(
          chatId: chatId.value,
          senderId: currentUserId.value,
          senderType: userType.value,
          message: captionController.text.trim(),
          attachment: file,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to send attachment: ${e.toString()}');
    }
  }
  
  void viewAttachment(String url) {
    Get.toNamed(
      '/image-viewer',
      arguments: {'url': url},
    );
  }
  
  void viewCollaboration() {
    if (collaborationId.value.isEmpty) return;
    
    Get.toNamed(
      Routes.COLLABORATION_DETAIL,
      arguments: {'collaborationId': collaborationId.value},
    );
  }
}