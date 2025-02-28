import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../constants/app_constants.dart';
import '../models/user_model.dart';
import '../models/brand_model.dart';
import '../models/creator_model.dart';
import '../models/campaign_model.dart';
import '../models/collaboration_model.dart';
import '../models/chat_models.dart';
import '../models/wallet_models.dart';

class FirestoreService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();
  
  // Users collection
  CollectionReference get users => _firestore.collection(AppConstants.usersCollection);
  CollectionReference get brands => _firestore.collection(AppConstants.brandsCollection);
  CollectionReference get creators => _firestore.collection(AppConstants.creatorsCollection);
  
  // Content collections
  CollectionReference get campaigns => _firestore.collection(AppConstants.campaignsCollection);
  CollectionReference get collaborations => _firestore.collection(AppConstants.collaborationsCollection);
  CollectionReference get chats => _firestore.collection(AppConstants.chatsCollection);
  CollectionReference get messages => _firestore.collection(AppConstants.messagesCollection);
  
  // Financial collections
  CollectionReference get wallets => _firestore.collection(AppConstants.walletsCollection);
  CollectionReference get transactions => _firestore.collection(AppConstants.transactionsCollection);
  CollectionReference get contracts => _firestore.collection(AppConstants.contractsCollection);
  
  // User operations
  Future<void> createUser(UserModel user) async {
    await users.doc(user.id).set(user.toMap());
  }
  
  Future<DocumentSnapshot?> getUser(String id) async {
    try {
      return await users.doc(id).get();
    } catch (e) {
      return null;
    }
  }
  
  Future<void> updateUser(UserModel user) async {
    await users.doc(user.id).update(user.toMap());
  }
  
  // Brand operations
  Future<void> createBrand(BrandModel brand) async {
    await brands.doc(brand.id).set(brand.toMap());
  }
  
  Future<DocumentSnapshot?> getBrand(String id) async {
    try {
      return await brands.doc(id).get();
    } catch (e) {
      return null;
    }
  }
  
  Future<void> updateBrand(BrandModel brand) async {
    await brands.doc(brand.id).update(brand.toMap());
  }
  
  Future<List<DocumentSnapshot>> getAllBrands() async {
    final snapshot = await brands.get();
    return snapshot.docs;
  }
  
  // Creator operations
  Future<void> createCreator(CreatorModel creator) async {
    await creators.doc(creator.id).set(creator.toMap());
  }
  
  Future<DocumentSnapshot?> getCreator(String id) async {
    try {
      return await creators.doc(id).get();
    } catch (e) {
      return null;
    }
  }
  
  Future<void> updateCreator(CreatorModel creator) async {
    await creators.doc(creator.id).update(creator.toMap());
  }
  
  Future<List<DocumentSnapshot>> getAllCreators() async {
    final snapshot = await creators.get();
    return snapshot.docs;
  }
  
  Future<List<DocumentSnapshot>> getCreatorsByCategories(List<String> categories) async {
    final snapshot = await creators
        .where('mainCategory', whereIn: categories)
        .get();
    return snapshot.docs;
  }
  
  // Campaign operations
  Future<String> createCampaign(CampaignModel campaign) async {
    final campaignId = _uuid.v4();
    final newCampaign = campaign.copyWith(id: campaignId);
    await campaigns.doc(campaignId).set(newCampaign.toMap());
    return campaignId;
  }
  
  Future<DocumentSnapshot?> getCampaign(String id) async {
    try {
      return await campaigns.doc(id).get();
    } catch (e) {
      return null;
    }
  }
  
  Future<void> updateCampaign(CampaignModel campaign) async {
    await campaigns.doc(campaign.id).update(campaign.toMap());
  }
  
  Future<List<DocumentSnapshot>> getBrandCampaigns(String brandId) async {
    final snapshot = await campaigns
        .where('brandId', isEqualTo: brandId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs;
  }
  
  Future<List<DocumentSnapshot>> getActiveCampaigns() async {
    final snapshot = await campaigns
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs;
  }
  
  Future<List<DocumentSnapshot>> getCampaignsByContentType(String contentType) async {
    final snapshot = await campaigns
        .where('requiredContentTypes', arrayContains: contentType)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs;
  }
  
  // Collaboration operations
  Future<String> createCollaboration(CollaborationModel collaboration) async {
    final collaborationId = _uuid.v4();
    final newCollaboration = collaboration.copyWith(id: collaborationId);
    await collaborations.doc(collaborationId).set(newCollaboration.toMap());
    return collaborationId;
  }
  
  Future<DocumentSnapshot?> getCollaboration(String id) async {
    try {
      return await collaborations.doc(id).get();
    } catch (e) {
      return null;
    }
  }
  
  Future<void> updateCollaboration(CollaborationModel collaboration) async {
    await collaborations.doc(collaboration.id).update(collaboration.toMap());
  }
  
  Future<List<DocumentSnapshot>> getBrandCollaborations(String brandId) async {
    final snapshot = await collaborations
        .where('brandId', isEqualTo: brandId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs;
  }
  
  Future<List<DocumentSnapshot>> getCreatorCollaborations(String creatorId) async {
    final snapshot = await collaborations
        .where('creatorId', isEqualTo: creatorId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs;
  }
  
  Future<List<DocumentSnapshot>> getCampaignCollaborations(String campaignId) async {
    final snapshot = await collaborations
        .where('campaignId', isEqualTo: campaignId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs;
  }
  
  // Chat operations
  Future<String> createChat(ChatModel chat) async {
    final chatId = _uuid.v4();
    final newChat = chat.copyWith(id: chatId);
    await chats.doc(chatId).set(newChat.toMap());
    return chatId;
  }
  
  Future<DocumentSnapshot?> getChat(String id) async {
    try {
      return await chats.doc(id).get();
    } catch (e) {
      return null;
    }
  }
  
  Future<DocumentSnapshot?> getChatByCollaboration(String collaborationId) async {
    try {
      final snapshot = await chats
          .where('collaborationId', isEqualTo: collaborationId)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  Future<void> updateChat(ChatModel chat) async {
    await chats.doc(chat.id).update(chat.toMap());
  }
  
  Future<List<DocumentSnapshot>> getBrandChats(String brandId) async {
    final snapshot = await chats
        .where('brandId', isEqualTo: brandId)
        .orderBy('lastMessageTime', descending: true)
        .get();
    return snapshot.docs;
  }
  
  Future<List<DocumentSnapshot>> getCreatorChats(String creatorId) async {
    final snapshot = await chats
        .where('creatorId', isEqualTo: creatorId)
        .orderBy('lastMessageTime', descending: true)
        .get();
    return snapshot.docs;
  }
  
  // Message operations
  Future<String> sendMessage(MessageModel message) async {
    final messageId = _uuid.v4();
    final newMessage = message.copyWith(id: messageId);
    
    // Update the chat's last message info
    final chatDoc = await getChat(message.chatId);
    if (chatDoc != null) {
      final chat = ChatModel.fromFirestore(chatDoc);
      final unreadCount = Map<String, int>.from(chat.unreadCount);
      
      // Increment unread count for the recipient
      String recipientId;
      if (message.senderType == AppConstants.userTypeBrand) {
        recipientId = chat.creatorId;
      } else {
        recipientId = chat.brandId;
      }
      unreadCount[recipientId] = (unreadCount[recipientId] ?? 0) + 1;
      
      // Update chat
      await updateChat(chat.copyWith(
        lastMessage: message.message,
        lastMessageTime: message.createdAt,
        lastSenderId: message.senderId,
        unreadCount: unreadCount,
      ));
    }
    
    // Save the message
    await messages.doc(messageId).set(newMessage.toMap());
    return messageId;
  }
  
  Future<List<DocumentSnapshot>> getChatMessages(String chatId) async {
    final snapshot = await messages
        .where('chatId', isEqualTo: chatId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs;
  }
  
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    // Update unread count in chat
    final chatDoc = await getChat(chatId);
    if (chatDoc != null) {
      final chat = ChatModel.fromFirestore(chatDoc);
      final unreadCount = Map<String, int>.from(chat.unreadCount);
      unreadCount[userId] = 0;
      
      await updateChat(chat.copyWith(
        unreadCount: unreadCount,
      ));
    }
    
    // Mark all messages as read
    final batch = _firestore.batch();
    final unreadMessages = await messages
        .where('chatId', isEqualTo: chatId)
        .where('isRead', isEqualTo: false)
        .where('senderId', isNotEqualTo: userId)
        .get();
    
    for (var doc in unreadMessages.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    
    await batch.commit();
  }
  
  // Wallet operations
  Future<void> createWallet(String userId, String userType) async {
    final wallet = WalletModel(
      id: userId,
      userId: userId,
      userType: userType,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    await wallets.doc(userId).set(wallet.toMap());
  }
  
  Future<DocumentSnapshot?> getWallet(String userId) async {
    try {
      return await wallets.doc(userId).get();
    } catch (e) {
      return null;
    }
  }
  
  Future<void> updateWallet(WalletModel wallet) async {
    await wallets.doc(wallet.id).update(wallet.toMap());
  }
  
  // Transaction operations
  Future<String> createTransaction(TransactionModel transaction) async {
    final transactionId = _uuid.v4();
    final newTransaction = transaction.copyWith(id: transactionId);
    await transactions.doc(transactionId).set(newTransaction.toMap());
    return transactionId;
  }
  
  Future<List<DocumentSnapshot>> getUserTransactions(String userId) async {
    final snapshot = await transactions
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs;
  }
  
  Future<void> updateTransactionStatus(
    String transactionId, 
    String status, 
    {DateTime? completedAt}
  ) async {
    final updateData = <String, dynamic>{
      'status': status,
    };
    
    if (completedAt != null) {
      updateData['completedAt'] = completedAt;
    }
    
    await transactions.doc(transactionId).update(updateData);
  }
  
  // Contract operations
  Future<String> createContract(Map<String, dynamic> contractData) async {
    final contractId = _uuid.v4();
    contractData['id'] = contractId;
    contractData['createdAt'] = DateTime.now();
    
    await contracts.doc(contractId).set(contractData);
    return contractId;
  }
  
  Future<DocumentSnapshot?> getContract(String id) async {
    try {
      return await contracts.doc(id).get();
    } catch (e) {
      return null;
    }
  }
}