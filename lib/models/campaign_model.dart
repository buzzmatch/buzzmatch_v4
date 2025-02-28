import 'package:cloud_firestore/cloud_firestore.dart';

class CampaignModel {
  final String id;
  final String brandId;
  final String brandName;
  final String? brandLogo;
  final String campaignName;
  final String productName;
  final List<String> requiredContentTypes;
  final String description;
  final double budget;
  final DateTime deadline;
  final List<String> referenceUrls;
  final List<String> invitedCreators;
  final List<String> appliedCreators;
  final List<String> selectedCreators;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  CampaignModel({
    required this.id,
    required this.brandId,
    required this.brandName,
    this.brandLogo,
    required this.campaignName,
    required this.productName,
    required this.requiredContentTypes,
    required this.description,
    required this.budget,
    required this.deadline,
    this.referenceUrls = const [],
    this.invitedCreators = const [],
    this.appliedCreators = const [],
    this.selectedCreators = const [],
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'brandId': brandId,
      'brandName': brandName,
      'brandLogo': brandLogo,
      'campaignName': campaignName,
      'productName': productName,
      'requiredContentTypes': requiredContentTypes,
      'description': description,
      'budget': budget,
      'deadline': deadline,
      'referenceUrls': referenceUrls,
      'invitedCreators': invitedCreators,
      'appliedCreators': appliedCreators,
      'selectedCreators': selectedCreators,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory CampaignModel.fromMap(Map<String, dynamic> map) {
    return CampaignModel(
      id: map['id'] ?? '',
      brandId: map['brandId'] ?? '',
      brandName: map['brandName'] ?? '',
      brandLogo: map['brandLogo'],
      campaignName: map['campaignName'] ?? '',
      productName: map['productName'] ?? '',
      requiredContentTypes: List<String>.from(map['requiredContentTypes'] ?? []),
      description: map['description'] ?? '',
      budget: map['budget']?.toDouble() ?? 0.0,
      deadline: (map['deadline'] as Timestamp).toDate(),
      referenceUrls: List<String>.from(map['referenceUrls'] ?? []),
      invitedCreators: List<String>.from(map['invitedCreators'] ?? []),
      appliedCreators: List<String>.from(map['appliedCreators'] ?? []),
      selectedCreators: List<String>.from(map['selectedCreators'] ?? []),
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  factory CampaignModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CampaignModel.fromMap({
      'id': doc.id,
      ...data,
    });
  }

  CampaignModel copyWith({
    String? id,
    String? brandId,
    String? brandName,
    String? brandLogo,
    String? campaignName,
    String? productName,
    List<String>? requiredContentTypes,
    String? description,
    double? budget,
    DateTime? deadline,
    List<String>? referenceUrls,
    List<String>? invitedCreators,
    List<String>? appliedCreators,
    List<String>? selectedCreators,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CampaignModel(
      id: id ?? this.id,
      brandId: brandId ?? this.brandId,
      brandName: brandName ?? this.brandName,
      brandLogo: brandLogo ?? this.brandLogo,
      campaignName: campaignName ?? this.campaignName,
      productName: productName ?? this.productName,
      requiredContentTypes: requiredContentTypes ?? this.requiredContentTypes,
      description: description ?? this.description,
      budget: budget ?? this.budget,
      deadline: deadline ?? this.deadline,
      referenceUrls: referenceUrls ?? this.referenceUrls,
      invitedCreators: invitedCreators ?? this.invitedCreators,
      appliedCreators: appliedCreators ?? this.appliedCreators,
      selectedCreators: selectedCreators ?? this.selectedCreators,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}