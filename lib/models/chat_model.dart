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

  // Add any necessary methods or factory constructors here
} 