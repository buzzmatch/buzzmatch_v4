// ignore_for_file: non_constant_identifier_names

import 'package:get/get.dart';

// Import screens
import '../screens/splash/splash_screen.dart';
import '../screens/welcome/welcome_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/dashboard/brand/brand_dashboard_screen.dart';
import '../screens/dashboard/creator/creator_dashboard_screen.dart';
import '../screens/campaigns/campaign_list_screen.dart';
import '../screens/campaigns/campaign_detail_screen.dart';
import '../screens/campaigns/campaign_create_screen.dart';
import '../screens/collaborations/collaboration_detail_screen.dart';
import '../screens/chat/chat_list_screen.dart';
import '../screens/chat/chat_detail_screen.dart';
import '../screens/payment/wallet_screen.dart';
import '../screens/payment/transaction_history_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/profile_edit_screen.dart';

class AppPages {
  static const INITIAL = 'splash';

  static final routes = [
    GetPage(name: 'splash', page: () => const SplashScreen()),
    GetPage(name: 'welcome', page: () => const WelcomeScreen()),
    GetPage(name: 'login', page: () => LoginScreen()),
    GetPage(name: 'signup', page: () => SignupScreen()),
    GetPage(name: 'brand_dashboard', page: () => const BrandDashboardScreen()),
    GetPage(name: 'creator_dashboard', page: () => const CreatorDashboardScreen()),
    GetPage(name: 'campaign_list', page: () => const CampaignListScreen()),
    GetPage(name: 'campaign_detail', page: () => const CampaignDetailScreen()),
    GetPage(name: 'campaign_create', page: () => const CampaignCreateScreen()),
    GetPage(name: 'collaboration_detail', page: () => const CollaborationDetailScreen()),
    GetPage(name: 'chat_list', page: () => const ChatListScreen()),
    GetPage(name: 'chat_detail', page: () => const ChatDetailScreen()),
    GetPage(name: 'wallet', page: () => const WalletScreen()),
    GetPage(name: 'transaction_history', page: () => const TransactionHistoryScreen()),
    GetPage(name: 'profile', page: () => const ProfileScreen()),
    GetPage(name: 'profile_edit', page: () => const ProfileEditScreen()),
  ];
}

class Routes {
  static const String TRANSACTION_HISTORY = '/transaction-history';
  static const String COLLABORATION_DETAIL = '/collaboration-detail';
  static const String CHAT_LIST = '/chat-list';
  static const String PROFILE_EDIT = '/profile-edit';
  static const String LOGIN = '/login';
}
