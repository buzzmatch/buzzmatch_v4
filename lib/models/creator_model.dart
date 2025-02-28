import 'package:cloud_firestore/cloud_firestore.dart';

class CreatorModel {
  final String id;
  final String userId;
  final String fullName;
  final String email;
  final String phone;
  final String contentType;
  final String mainCategory;
  final String country;
  final String? bio;
  final String? profileImage;
  final List<String> portfolioUrls;
  final List<String> socialLinks;
  final Map<String, int> stats; // followers, likes, etc.
  final DateTime createdAt;
  final DateTime updatedAt;

  CreatorModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.contentType,
    required this.mainCategory,
    required this.country,
    this.bio,
    this.profileImage,
    this.portfolioUrls = const [],
    this.socialLinks = const [],
    this.stats = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'contentType': contentType,
      'mainCategory': mainCategory,
      'country': country,
      'bio': bio,
      'profileImage': profileImage,
      'portfolioUrls': portfolioUrls,
      'socialLinks': socialLinks,
      'stats': stats,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory CreatorModel.fromMap(Map<String, dynamic> map) {
    return CreatorModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      contentType: map['contentType'] ?? '',
      mainCategory: map['mainCategory'] ?? '',
      country: map['country'] ?? '',
      bio: map['bio'],
      profileImage: map['profileImage'],
      portfolioUrls: List<String>.from(map['portfolioUrls'] ?? []),
      socialLinks: List<String>.from(map['socialLinks'] ?? []),
      stats: Map<String, int>.from(map['stats'] ?? {}),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  factory CreatorModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CreatorModel.fromMap({
      'id': doc.id,
      ...data,
    });
  }

  CreatorModel copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? email,
    String? phone,
    String? contentType,
    String? mainCategory,
    String? country,
    String? bio,
    String? profileImage,
    List<String>? portfolioUrls,
    List<String>? socialLinks,
    Map<String, int>? stats,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CreatorModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      contentType: contentType ?? this.contentType,
      mainCategory: mainCategory ?? this.mainCategory,
      country: country ?? this.country,
      bio: bio ?? this.bio,
      profileImage: profileImage ?? this.profileImage,
      portfolioUrls: portfolioUrls ?? this.portfolioUrls,
      socialLinks: socialLinks ?? this.socialLinks,
      stats: stats ?? this.stats,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}