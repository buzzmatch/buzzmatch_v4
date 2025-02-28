import 'package:get/get.dart';

import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/storage_service.dart';
import 'services/payment_service.dart';
import 'services/notification_service.dart';
import 'services/language_service.dart';
import 'services/chat_service.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Core services
    Get.put(AuthService(), permanent: true);
    Get.put(FirestoreService(), permanent: true);
    Get.put(StorageService(), permanent: true);
    Get.put(PaymentService(), permanent: true);
    Get.put(NotificationService(), permanent: true);
    Get.put(LanguageService(), permanent: true);
    Get.put(ChatService(), permanent: true);
  }
}