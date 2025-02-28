import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

class LanguageService extends GetxService {
  late SharedPreferences _prefs;
  final RxString currentLanguage = RxString(AppConstants.defaultLanguage);
  
  Locale get currentLocale {
    if (currentLanguage.value == 'ar') {
      return const Locale('ar', 'SA');
    } else {
      return const Locale('en', 'US');
    }
  }
  
  Future<LanguageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    final savedLanguage = _prefs.getString('language') ?? AppConstants.defaultLanguage;
    currentLanguage.value = savedLanguage;
    return this;
  }
  
  Future<void> changeLanguage(String languageCode) async {
    currentLanguage.value = languageCode;
    
    if (languageCode == 'ar') {
      await Get.updateLocale(const Locale('ar', 'SA'));
    } else {
      await Get.updateLocale(const Locale('en', 'US'));
    }
    
    await _prefs.setString('language', languageCode);
  }
  
  bool get isArabic => currentLanguage.value == 'ar';
}