import 'dart:io';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chat_models.dart';
import 'firestore_service.dart';
import 'storage_service.dart';
import 'notification_service.dart';

class ChatService extends GetxService {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final StorageService _storageService = Get.find<StorageService>();
  final NotificationService _notificationService = Get.find<NotificationService>();
  
  // Get chat details
  Future<ChatModel?> getChatDetails(String chatId) async {
    final chatDoc = await _firestoreService.getChat(chatId);
    if (chatDoc != null) {
      return ChatModel.fromFirestore(chatDoc);
    }
    return null;
  }
  
  // Get chat by collaboration
  Future<ChatModel?> getChatByCollaboration(String collaborationId) async {
    final chatDoc = await _firestoreService.getChatByCollaboration(collaborationId);
    if (chatDoc != null) {
      return ChatModel.fromFirestore(chatDoc);
    }
    return null;
  }
  
  // Create a new chat for collaboration
  Future<String?> createChat({
    required String campaignId,
    required String collaborationId,
    required String brandId,
    required String creatorId,
  }) async {
    final now = DateTime.now();
    
    final chat = ChatModel(
      id: '',
      campaignId: campaignId,
      collaborationId: collaborationId,
      brandId: brandId,
      creatorId: creatorId,
      lastMessageTime: now,
      lastMessage: 'Chat started',
      lastSenderId: brandId, // Default to brand as initiator
      unreadCount: {
        brandId: 0,
        creatorId: 1, // Creator has 1 unread message initially
      },
      createdAt: now,
      updatedAt: now,
    );
    
    final chatId = await _firestoreService.createChat(chat);
    
    // Send system message about chat creation
    final systemMessage = MessageModel(
      id: '',
      chatId: chatId,
      senderId: 'system',
      senderType: 'system',
      message: 'Chat started for collaboration',
      isRead: false,
      createdAt: now,
    );
    
    await _firestoreService.sendMessage(systemMessage);
    
    return chatId;
  }
  
  // Send a text message
  Future<String?> sendTextMessage({
    required String chatId,
    required String senderId,
    required String senderType,
    required String message,
  }) async {
    final messageModel = MessageModel(
      id: '',
      chatId: chatId,
      senderId: senderId,
      senderType: senderType,
      message: message,
      isRead: false,
      createdAt: DateTime.now(),
    );
    
    final messageId = await _firestoreService.sendMessage(messageModel);
    
    // Get chat data to determine recipient
    final chatDoc = await _firestoreService.getChat(chatId);
    if (chatDoc != null) {
      final chat = ChatModel.fromFirestore(chatDoc);
      
      // Determine recipient ID
      String recipientId;
      if (senderType == 'brand') {
        recipientId = chat.creatorId;
      } else {
        recipientId = chat.brandId;
      }
      
      // Send notification to recipient
      _notificationService.sendChatNotification(
        recipientId: recipientId,
        senderName: senderType == 'brand' ? 'Brand' : 'Creator', // Will be replaced with actual names
        message: message,
        chatId: chatId,
      );
    }
    
    return messageId;
  }
  
  // Send a message with attachment
  Future<String?> sendMessageWithAttachment({
    required String chatId,
    required String senderId,
    required String senderType,
    required String message,
    required File attachment,
  }) async {
    // Upload attachment
    final attachmentUrl = await _storageService.uploadChatAttachment(attachment, chatId);
    
    if (attachmentUrl == null) {
      Get.snackbar('Error', 'Failed to upload attachment');
      return null;
    }
    
    final messageModel = MessageModel(
      id: '',
      chatId: chatId,
      senderId: senderId,
      senderType: senderType,
      message: message,
      attachments: [attachmentUrl],
      isRead: false,
      createdAt: DateTime.now(),
    );
    
    final messageId = await _firestoreService.sendMessage(messageModel);
    
    // Get chat data to determine recipient
    final chatDoc = await _firestoreService.getChat(chatId);
    if (chatDoc != null) {
      final chat = ChatModel.fromFirestore(chatDoc);
      
      // Determine recipient ID
      String recipientId;
      if (senderType == 'brand') {
        recipientId = chat.creatorId;
      } else {
        recipientId = chat.brandId;
      }
      
      // Send notification to recipient
      _notificationService.sendChatNotification(
        recipientId: recipientId,
        senderName: senderType == 'brand' ? 'Brand' : 'Creator',
        message: 'Sent an attachment',
        chatId: chatId,
      );
    }
    
    return messageId;
  }
  
  // Get messages for a chat
  Future<List<MessageModel>> getChatMessages(String chatId) async {
    final messageDocs = await _firestoreService.getChatMessages(chatId);
    return messageDocs.map((doc) => MessageModel.fromFirestore(doc)).toList();
  }
  
  // Mark messages as read
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    await _firestoreService.markMessagesAsRead(chatId, userId);
  }
  
  // Stream of messages for real-time updates
  Stream<QuerySnapshot> getChatMessagesStream(String chatId) {
    return _firestoreService.messages
        .where('chatId', isEqualTo: chatId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
  
  // Stream of chats for a user (brand or creator)
  Stream<QuerySnapshot> getUserChatsStream(String userId, String userType) {
    if (userType == 'brand') {
      return _firestoreService.chats
          .where('brandId', isEqualTo: userId)
          .orderBy('lastMessageTime', descending: true)
          .snapshots();
    } else {
      return _firestoreService.chats
          .where('creatorId', isEqualTo: userId)
          .orderBy('lastMessageTime', descending: true)
          .snapshots();
    }
  }
}