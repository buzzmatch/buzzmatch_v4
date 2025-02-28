import 'package:cloud_firestore/cloud_firestore.dart';

class BrandModel {
  final String id;
  final String userId;
  final String companyName;
  final String email;
  final String phone;
  final String businessCategory;
  final String country;
  final String? logoUrl;
  final String? websiteUrl;
  final String? description;
  final List<String> socialLinks;
  final DateTime createdAt;
  final DateTime updatedAt;

  BrandModel({
    required this.id,
    required this.userId,
    required this.companyName,
    required this.email,
    required this.phone,
    required this.businessCategory,
    required this.country,
    this.logoUrl,
    this.websiteUrl,
    this.description,
    this.socialLinks = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'companyName': companyName,
      'email': email,
      'phone': phone,
      'businessCategory': businessCategory,
      'country': country,
      'logoUrl': logoUrl,
      'websiteUrl': websiteUrl,
      'description': description,
      'socialLinks': socialLinks,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory BrandModel.fromMap(Map<String, dynamic> map) {
    return BrandModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      companyName: map['companyName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      businessCategory: map['businessCategory'] ?? '',
      country: map['country'] ?? '',
      logoUrl: map['logoUrl'],
      websiteUrl: map['websiteUrl'],
      description: map['description'],
      socialLinks: List<String>.from(map['socialLinks'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  factory BrandModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BrandModel.fromMap({
      'id': doc.id,
      ...data,
    });
  }

  BrandModel copyWith({
    String? id,
    String? userId,
    String? companyName,
    String? email,
    String? phone,
    String? businessCategory,
    String? country,
    String? logoUrl,
    String? websiteUrl,
    String? description,
    List<String>? socialLinks,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BrandModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      companyName: companyName ?? this.companyName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      businessCategory: businessCategory ?? this.businessCategory,
      country: country ?? this.country,
      logoUrl: logoUrl ?? this.logoUrl,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      description: description ?? this.description,
      socialLinks: socialLinks ?? this.socialLinks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}