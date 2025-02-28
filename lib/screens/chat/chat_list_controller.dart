import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/chat_models.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../constants/app_constants.dart';
import '../../routes/app_pages.dart';

class ChatListController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  
  // Observable variables
  final RxBool isLoading = true.obs;
  final RxString userType = ''.obs;
  final RxString currentUserId = ''.obs;
  final RxList<ChatModel> chats = <ChatModel>[].obs;
  
  // Stream subscription
  late Stream<QuerySnapshot> chatsStream;
  
  // Map to store information about brands/creators
  final Map<String, Map<String, String>> partyInfoMap = {};
  
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
    
    if (currentUserId.value.isNotEmpty) {
      // Set up stream listener
      setupChatsStream();
    } else {
      isLoading.value = false;
    }
  }
  
  
  void setupChatsStream() {
    isLoading.value = true;
    
    if (userType.value == AppConstants.userTypeBrand) {
      // Brand chats
      chatsStream = _firestoreService.chats
          .where('brandId', isEqualTo: currentUserId.value)
          .orderBy('lastMessageTime', descending: true)
          .snapshots();
    } else {
      // Creator chats
      chatsStream = _firestoreService.chats
          .where('creatorId', isEqualTo: currentUserId.value)
          .orderBy('lastMessageTime', descending: true)
          .snapshots();
    }
    
    // Listen to the stream
    chatsStream.listen((snapshot) {
      final List<ChatModel> chatsList = snapshot.docs
          .map((doc) => ChatModel.fromFirestore(doc))
          .toList();
      
      chats.value = chatsList;
      
      // Fetch other party information for each chat
      for (var chat in chatsList) {
        fetchOtherPartyInfo(chat);
      }
      
      isLoading.value = false;
    }, onError: (error) {
      print('Error listening to chats: $error');
      isLoading.value = false;
    });
  }
  
  Future<void> fetchOtherPartyInfo(ChatModel chat) async {
    try {
      if (userType.value == AppConstants.userTypeBrand) {
        // Fetch creator info
        final creatorId = chat.creatorId;
        
        // Check if already fetched
        if (!partyInfoMap.containsKey(creatorId)) {
          final creatorDoc = await _firestoreService.getCreator(creatorId);
          if (creatorDoc != null) {
            final creatorData = creatorDoc.data() as Map<String, dynamic>;
            partyInfoMap[creatorId] = {
              'name': creatorData['fullName'] ?? 'Unknown Creator',
              'image': creatorData['profileImage'],
            };
            
            // Trigger UI update
            chats.refresh();
          }
        }
      } else {
        // Fetch brand info
        final brandId = chat.brandId;
        
        // Check if already fetched
        if (!partyInfoMap.containsKey(brandId)) {
          final brandDoc = await _firestoreService.getBrand(brandId);
          if (brandDoc != null) {
            final brandData = brandDoc.data() as Map<String, dynamic>;
            partyInfoMap[brandId] = {
              'name': brandData['companyName'] ?? 'Unknown Brand',
              'image': brandData['logoUrl'],
            };
            
            // Trigger UI update
            chats.refresh();
          }
        }
      }
    } catch (e) {
      print('Error fetching party info: $e');
    }
  }
  
  void openChatDetail(String chatId) {
    // Mark messages as read
    _firestoreService.markMessagesAsRead(chatId, currentUserId.value);
    
    // Navigate to chat detail
    Get.toNamed(
      '/chat-detail',
      arguments: {'chatId': chatId},
    );
  }
}