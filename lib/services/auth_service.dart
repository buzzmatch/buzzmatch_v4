import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../models/user_model.dart';
import '../models/brand_model.dart';
import '../models/creator_model.dart';
import '../constants/app_constants.dart';
import 'firestore_service.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  
  final Rx<User?> firebaseUser = Rx<User?>(null);
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final Rx<BrandModel?> currentBrand = Rx<BrandModel?>(null);
  final Rx<CreatorModel?> currentCreator = Rx<CreatorModel?>(null);
  
  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_auth.authStateChanges());
    ever(firebaseUser, _setInitialScreen);
  }
  
  void _setInitialScreen(User? user) async {
    if (user == null) {
      currentUser.value = null;
      currentBrand.value = null;
      currentCreator.value = null;
      Get.offAllNamed('/welcome');
    } else {
      // Fetch user data
      await getUserData();
      
      // Navigate based on user type
      if (currentUser.value != null) {
        if (currentUser.value!.userType == AppConstants.userTypeBrand) {
          Get.offAllNamed('/brand-dashboard');
        } else {
          Get.offAllNamed('/creator-dashboard');
        }
      }
    }
  }
  
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
      return null;
    }
  }
  
  Future<UserCredential?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
      return null;
    }
  }
  
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
      return null;
    }
  }
  
  Future<UserCredential?> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );
      
      return await _auth.signInWithCredential(oauthCredential);
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
      return null;
    } catch (e) {
      Get.snackbar('Error', 'Failed to sign in with Apple');
      return null;
    }
  }
  
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      Get.snackbar('Error', 'Failed to sign out');
    }
  }
  
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      Get.snackbar('Success', 'Password reset email sent to $email');
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
    }
  }
  
  Future<void> createUserData({
    required String userType,
    required Map<String, dynamic> userData,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      
      // Create user record
      final UserModel userModel = UserModel(
        id: user.uid,
        email: user.email ?? userData['email'],
        phone: userData['phone'],
        country: userData['country'],
        userType: userType,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _firestoreService.createUser(userModel);
      
      // Create specific user type record
      if (userType == AppConstants.userTypeBrand) {
        final BrandModel brandModel = BrandModel(
          id: user.uid,
          userId: user.uid,
          companyName: userData['companyName'],
          email: user.email ?? userData['email'],
          phone: userData['phone'],
          businessCategory: userData['businessCategory'],
          country: userData['country'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        await _firestoreService.createBrand(brandModel);
      } else {
        final CreatorModel creatorModel = CreatorModel(
          id: user.uid,
          userId: user.uid,
          fullName: userData['fullName'],
          email: user.email ?? userData['email'],
          phone: userData['phone'],
          contentType: userData['contentType'],
          mainCategory: userData['mainCategory'],
          country: userData['country'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        await _firestoreService.createCreator(creatorModel);
      }
      
      // Create wallet for user
      await _firestoreService.createWallet(user.uid, userType);
      
      // Fetch user data
      await getUserData();
    } catch (e) {
      Get.snackbar('Error', 'Failed to create user data');
    }
  }
  
  Future<void> getUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      
      // Get user record
      final userDoc = await _firestoreService.getUser(user.uid);
      if (userDoc != null) {
        currentUser.value = UserModel.fromFirestore(userDoc);
        
        // Get specific user type record
        if (currentUser.value!.userType == AppConstants.userTypeBrand) {
          final brandDoc = await _firestoreService.getBrand(user.uid);
          if (brandDoc != null) {
            currentBrand.value = BrandModel.fromFirestore(brandDoc);
          }
        } else {
          final creatorDoc = await _firestoreService.getCreator(user.uid);
          if (creatorDoc != null) {
            currentCreator.value = CreatorModel.fromFirestore(creatorDoc);
          }
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to get user data');
    }
  }
  
  void _handleAuthException(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'user-not-found':
        message = 'No user found with this email.';
        break;
      case 'wrong-password':
        message = 'Wrong password provided.';
        break;
      case 'email-already-in-use':
        message = 'The email address is already in use.';
        break;
      case 'weak-password':
        message = 'The password is too weak.';
        break;
      case 'invalid-email':
        message = 'The email address is invalid.';
        break;
      default:
        message = e.message ?? 'An unknown error occurred.';
    }
    Get.snackbar('Authentication Error', message);
  }
}