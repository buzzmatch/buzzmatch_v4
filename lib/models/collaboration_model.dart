import 'package:cloud_firestore/cloud_firestore.dart';

class CollaborationModel {
  final String id;
  final String campaignId;
  final String brandId;
  final String creatorId;
  final String status;
  final String? contract;
  final double budget;
  final List<String> contentUrls;
  final List<String> feedbackNotes;
  final DateTime? contractSignedDate;
  final DateTime? productShippedDate;
  final DateTime? contentSubmittedDate;
  final DateTime? approvedDate;
  final DateTime? paymentReleasedDate;
  final DateTime? completedDate;
  final bool isPaid;
  final DateTime createdAt;
  final DateTime updatedAt;

  CollaborationModel({
    required this.id,
    required this.campaignId,
    required this.brandId,
    required this.creatorId,
    required this.status,
    this.contract,
    required this.budget,
    this.contentUrls = const [],
    this.feedbackNotes = const [],
    this.contractSignedDate,
    this.productShippedDate,
    this.contentSubmittedDate,
    this.approvedDate,
    this.paymentReleasedDate,
    this.completedDate,
    this.isPaid = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'campaignId': campaignId,
      'brandId': brandId,
      'creatorId': creatorId,
      'status': status,
      'contract': contract,
      'budget': budget,
      'contentUrls': contentUrls,
      'feedbackNotes': feedbackNotes,
      'contractSignedDate': contractSignedDate,
      'productShippedDate': productShippedDate,
      'contentSubmittedDate': contentSubmittedDate,
      'approvedDate': approvedDate,
      'paymentReleasedDate': paymentReleasedDate,
      'completedDate': completedDate,
      'isPaid': isPaid,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory CollaborationModel.fromMap(Map<String, dynamic> map) {
    return CollaborationModel(
      id: map['id'] ?? '',
      campaignId: map['campaignId'] ?? '',
      brandId: map['brandId'] ?? '',
      creatorId: map['creatorId'] ?? '',
      status: map['status'] ?? '',
      contract: map['contract'],
      budget: map['budget']?.toDouble() ?? 0.0,
      contentUrls: List<String>.from(map['contentUrls'] ?? []),
      feedbackNotes: List<String>.from(map['feedbackNotes'] ?? []),
      contractSignedDate: map['contractSignedDate'] != null 
          ? (map['contractSignedDate'] as Timestamp).toDate() 
          : null,
      productShippedDate: map['productShippedDate'] != null 
          ? (map['productShippedDate'] as Timestamp).toDate() 
          : null,
      contentSubmittedDate: map['contentSubmittedDate'] != null 
          ? (map['contentSubmittedDate'] as Timestamp).toDate() 
          : null,
      approvedDate: map['approvedDate'] != null 
          ? (map['approvedDate'] as Timestamp).toDate() 
          : null,
      paymentReleasedDate: map['paymentReleasedDate'] != null 
          ? (map['paymentReleasedDate'] as Timestamp).toDate() 
          : null,
      completedDate: map['completedDate'] != null 
          ? (map['completedDate'] as Timestamp).toDate() 
          : null,
      isPaid: map['isPaid'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  factory CollaborationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CollaborationModel.fromMap({
      'id': doc.id,
      ...data,
    });
  }

  String get name => '';

  CollaborationModel copyWith({
    String? id,
    String? campaignId,
    String? brandId,
    String? creatorId,
    String? status,
    String? contract,
    double? budget,
    List<String>? contentUrls,
    List<String>? feedbackNotes,
    DateTime? contractSignedDate,
    DateTime? productShippedDate,
    DateTime? contentSubmittedDate,
    DateTime? approvedDate,
    DateTime? paymentReleasedDate,
    DateTime? completedDate,
    bool? isPaid,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CollaborationModel(
      id: id ?? this.id,
      campaignId: campaignId ?? this.campaignId,
      brandId: brandId ?? this.brandId,
      creatorId: creatorId ?? this.creatorId,
      status: status ?? this.status,
      contract: contract ?? this.contract,
      budget: budget ?? this.budget,
      contentUrls: contentUrls ?? this.contentUrls,
      feedbackNotes: feedbackNotes ?? this.feedbackNotes,
      contractSignedDate: contractSignedDate ?? this.contractSignedDate,
      productShippedDate: productShippedDate ?? this.productShippedDate,
      contentSubmittedDate: contentSubmittedDate ?? this.contentSubmittedDate,
      approvedDate: approvedDate ?? this.approvedDate,
      paymentReleasedDate: paymentReleasedDate ?? this.paymentReleasedDate,
      completedDate: completedDate ?? this.completedDate,
      isPaid: isPaid ?? this.isPaid,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}