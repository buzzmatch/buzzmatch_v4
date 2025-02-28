import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class StorageService extends GetxService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();
  
  Future<String?> uploadFile(File file, String folder) async {
    try {
      final fileName = '${_uuid.v4()}${p.extension(file.path)}';
      final Reference ref = _storage.ref().child('$folder/$fileName');
      
      final UploadTask uploadTask = ref.putFile(file);
      final TaskSnapshot taskSnapshot = await uploadTask;
      
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload file: ${e.toString()}');
      return null;
    }
  }
  
  Future<String?> uploadProfileImage(File file, String userId) async {
    return uploadFile(file, 'profile_images/$userId');
  }
  
  Future<String?> uploadBrandLogo(File file, String brandId) async {
    return uploadFile(file, 'brand_logos/$brandId');
  }
  
  Future<String?> uploadCampaignReference(File file, String campaignId) async {
    return uploadFile(file, 'campaign_references/$campaignId');
  }
  
  Future<String?> uploadCollaborationContent(File file, String collaborationId) async {
    return uploadFile(file, 'collaboration_content/$collaborationId');
  }
  
  Future<String?> uploadChatAttachment(File file, String chatId) async {
    return uploadFile(file, 'chat_attachments/$chatId');
  }
  
  Future<String?> uploadContractDocument(File file, String contractId) async {
    return uploadFile(file, 'contracts/$contractId');
  }
  
  Future<bool> deleteFile(String fileUrl) async {
    try {
      final Reference ref = _storage.refFromURL(fileUrl);
      await ref.delete();
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete file: ${e.toString()}');
      return false;
    }
  }
}