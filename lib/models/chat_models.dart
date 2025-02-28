import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id;
  final String campaignId;
  final String collaborationId;
  final String brandId;
  final String creatorId;
  final DateTime lastMessageTime;
  final String lastMessage;
  final String lastSenderId;
  final Map<String, int> unreadCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatModel({
    required this.id,
    required this.campaignId,
    required this.collaborationId,
    required this.brandId,
    required this.creatorId,
    required this.lastMessageTime,
    required this.lastMessage,
    required this.lastSenderId,
    required this.unreadCount,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'campaignId': campaignId,
      'collaborationId': collaborationId,
      'brandId': brandId,
      'creatorId': creatorId,
      'lastMessageTime': lastMessageTime,
      'lastMessage': lastMessage,
      'lastSenderId': lastSenderId,
      'unreadCount': unreadCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      id: map['id'] ?? '',
      campaignId: map['campaignId'] ?? '',
      collaborationId: map['collaborationId'] ?? '',
      brandId: map['brandId'] ?? '',
      creatorId: map['creatorId'] ?? '',
      lastMessageTime: (map['lastMessageTime'] as Timestamp).toDate(),
      lastMessage: map['lastMessage'] ?? '',
      lastSenderId: map['lastSenderId'] ?? '',
      unreadCount: Map<String, int>.from(map['unreadCount'] ?? {}),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatModel.fromMap({
      'id': doc.id,
      ...data,
    });
  }

  ChatModel copyWith({
    String? id,
    String? campaignId,
    String? collaborationId,
    String? brandId,
    String? creatorId,
    DateTime? lastMessageTime,
    String? lastMessage,
    String? lastSenderId,
    Map<String, int>? unreadCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatModel(
      id: id ?? this.id,
      campaignId: campaignId ?? this.campaignId,
      collaborationId: collaborationId ?? this.collaborationId,
      brandId: brandId ?? this.brandId,
      creatorId: creatorId ?? this.creatorId,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessage: lastMessage ?? this.lastMessage,
      lastSenderId: lastSenderId ?? this.lastSenderId,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String senderType; // 'brand' or 'creator'
  final String message;
  final List<String> attachments;
  final bool isRead;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderType,
    required this.message,
    this.attachments = const [],
    this.isRead = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'senderType': senderType,
      'message': message,
      'attachments': attachments,
      'isRead': isRead,
      'createdAt': createdAt,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] ?? '',
      chatId: map['chatId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderType: map['senderType'] ?? '',
      message: map['message'] ?? '',
      attachments: List<String>.from(map['attachments'] ?? []),
      isRead: map['isRead'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel.fromMap({
      'id': doc.id,
      ...data,
    });
  }

  MessageModel copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? senderType,
    String? message,
    List<String>? attachments,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      senderType: senderType ?? this.senderType,
      message: message ?? this.message,
      attachments: attachments ?? this.attachments,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}