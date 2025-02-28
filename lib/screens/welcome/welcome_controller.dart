import 'package:get/get.dart';
import '../../services/language_service.dart';
import '../../routes/app_pages.dart';

class WelcomeController extends GetxController {
  final LanguageService _languageService = Get.find<LanguageService>();
  
  void toggleLanguage() {
    if (_languageService.currentLanguage.value == 'en') {
      _languageService.changeLanguage('ar');
    } else {
      _languageService.changeLanguage('en');
    }
  }
  
  void navigateToAuth(String userType) {
    Get.toNamed(
      Routes.LOGIN,
      arguments: {'userType': userType},
    );
  }
}