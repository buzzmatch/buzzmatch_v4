class AppConstants {
  // App info
  static const String appName = 'BuzzMatch';
  static const String appVersion = '1.0.0';
  
  // Hive boxes
  static const String userBox = 'userBox';
  static const String settingsBox = 'settingsBox';
  
  // User types
  static const String userTypeCreator = 'creator';
  static const String userTypeBrand = 'brand';
  
  // Firestore collections
  static const String usersCollection = 'users';
  static const String brandsCollection = 'brands';
  static const String creatorsCollection = 'creators';
  static const String campaignsCollection = 'campaigns';
  static const String collaborationsCollection = 'collaborations';
  static const String chatsCollection = 'chats';
  static const String messagesCollection = 'messages';
  static const String walletsCollection = 'wallets';
  static const String transactionsCollection = 'transactions';
  static const String contractsCollection = 'contracts';
  
  // Collaboration status
  static const String statusMatched = 'Matched';
  static const String statusContractSigned = 'Contract Signed';
  static const String statusProductShipped = 'Product Shipped';
  static const String statusContentInProgress = 'Content In Progress';
  static const String statusSubmitted = 'Submitted';
  static const String statusRevision = 'Revision';
  static const String statusApproved = 'Approved';
  static const String statusPaymentReleased = 'Payment Released';
  static const String statusCompleted = 'Completed';
  
  // Payment status
  static const String paymentPending = 'Pending';
  static const String paymentCompleted = 'Completed';
  static const String paymentFailed = 'Failed';
  static const String paymentRefunded = 'Refunded';
  
  // Content types
  static const List<String> contentTypes = [
    'Photos',
    'Videos',
    'Stories',
    'Voiceover',
  ];
  
  // Business categories
  static const List<String> businessCategories = [
    'Fashion',
    'Beauty',
    'Food & Beverage',
    'Technology',
    'Health & Fitness',
    'Travel',
    'Entertainment',
    'Lifestyle',
    'Home & Decor',
    'Sports',
    'Education',
    'Finance',
    'Other',
  ];
  
  // Creator categories
  static const List<String> creatorCategories = [
    'Fashion',
    'Beauty',
    'Food',
    'Technology',
    'Fitness',
    'Travel',
    'Entertainment',
    'Lifestyle',
    'Gaming',
    'Education',
    'Business',
    'Other',
  ];
  
  // Payment methods
  static const List<String> paymentMethods = [
    'Bank Transfer',
    'Stripe',
    'PayPal',
    'Apple Pay',
    'STC Pay',
  ];
  
  // Currency
  static const String currency = 'SAR';
  
  // Default language
  static const String defaultLanguage = 'en';
}