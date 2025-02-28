import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService extends GetxService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  @override
  void onInit() {
    super.onInit();
    _initNotifications();
  }
  
  Future<void> _initNotifications() async {
    // Request permission
    await _requestPermissions();
    
    // Initialize local notifications
    const AndroidInitializationSettings androidInitializationSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosInitializationSettings = 
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    final InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );
    
    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
    
    // Handle FCM messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
    
    // Check for initial message
    final RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }
  
  Future<void> _requestPermissions() async {
    if (Platform.isIOS) {
      await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }
  
  void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap
    final payload = response.payload;
    if (payload != null) {
      try {
        final data = Map<String, dynamic>.from(Map<String, dynamic>.from(
            {"payload": payload}));
        
        // Navigate based on notification type
        _handleNotificationNavigation(data);
      } catch (e) {
        print('Error parsing notification payload: $e');
      }
    }
  }
  
  void _handleForegroundMessage(RemoteMessage message) {
    // Show local notification when app is in foreground
    final notification = message.notification;
    final data = message.data;
    
    if (notification != null) {
      _showLocalNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: notification.title ?? 'BuzzMatch',
        body: notification.body ?? '',
        payload: data.toString(),
      );
    }
  }
  
  void _handleNotificationTap(RemoteMessage message) {
    // Handle when user taps FCM notification
    _handleNotificationNavigation(message.data);
  }
  
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    // Extract information and navigate accordingly
    final notificationType = data['type'];
    
    switch (notificationType) {
      case 'chat':
        final chatId = data['chatId'];
        if (chatId != null) {
          Get.toNamed('/chat-detail', arguments: {'chatId': chatId});
        }
        break;
      case 'collaboration':
        final collaborationId = data['collaborationId'];
        if (collaborationId != null) {
          Get.toNamed('/collaboration-detail', arguments: {'collaborationId': collaborationId});
        }
        break;
      case 'campaign':
        final campaignId = data['campaignId'];
        if (campaignId != null) {
          Get.toNamed('/campaign-detail', arguments: {'campaignId': campaignId});
        }
        break;
      case 'payment':
        Get.toNamed('/wallet');
        break;
      default:
        // Default navigation (e.g., to dashboard)
        break;
    }
  }
  
  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'buzzmatch_channel',
      'BuzzMatch Notifications',
      channelDescription: 'Notifications from BuzzMatch app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _localNotifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
  
  // Save user's FCM token
  Future<void> saveToken(String userId) async {
    try {
      final token = await _firebaseMessaging.getToken();
      
      if (token != null) {
        await _firestore.collection('user_tokens').doc(userId).set({
          'token': token,
          'updatedAt': FieldValue.serverTimestamp(),
          'platform': Platform.isIOS ? 'ios' : 'android',
        });
      }
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }
  
  // Remove user's FCM token
  Future<void> removeToken(String userId) async {
    try {
      await _firestore.collection('user_tokens').doc(userId).delete();
    } catch (e) {
      print('Error removing FCM token: $e');
    }
  }
  
  // Send chat notification (this would be triggered from server in a real app)
  Future<void> sendChatNotification({
    required String recipientId,
    required String senderName,
    required String message,
    required String chatId,
  }) async {
    try {
      // In a real app, this would be done server-side
      // This is a placeholder for demonstration
      final tokenDoc = await _firestore.collection('user_tokens').doc(recipientId).get();
      
      if (tokenDoc.exists) {
        final token = tokenDoc.data()?['token'];
        
        if (token != null) {
          // Here we're simulating sending a notification
          // In a real app, this would be a server function
          print('Sending notification to token: $token');
          print('Payload: { chatId: $chatId, sender: $senderName, message: $message }');
          
          // For demo purposes, we'll show a local notification instead
          _showLocalNotification(
            id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
            title: 'Message from $senderName',
            body: message,
            payload: '{"type": "chat", "chatId": "$chatId"}',
          );
        }
      }
    } catch (e) {
      print('Error sending chat notification: $e');
    }
  }
  
  // Send collaboration notification (status change, etc.)
  Future<void> sendCollaborationNotification({
    required String recipientId,
    required String title,
    required String body,
    required String collaborationId,
  }) async {
    try {
      // For demo purposes, we'll show a local notification
      _showLocalNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: title,
        body: body,
        payload: '{"type": "collaboration", "collaborationId": "$collaborationId"}',
      );
    } catch (e) {
      print('Error sending collaboration notification: $e');
    }
  }
  
  // Send campaign notification (new campaigns, etc.)
  Future<void> sendCampaignNotification({
    required String recipientId,
    required String title,
    required String body,
    required String campaignId,
  }) async {
    try {
      // For demo purposes, we'll show a local notification
      _showLocalNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: title,
        body: body,
        payload: '{"type": "campaign", "campaignId": "$campaignId"}',
      );
    } catch (e) {
      print('Error sending campaign notification: $e');
    }
  }
  
  // Send payment notification
  Future<void> sendPaymentNotification({
    required String recipientId,
    required String title,
    required String body,
  }) async {
    try {
      // For demo purposes, we'll show a local notification
      _showLocalNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: title,
        body: body,
        payload: '{"type": "payment"}',
      );
    } catch (e) {
      print('Error sending payment notification: $e');
    }
  }
}