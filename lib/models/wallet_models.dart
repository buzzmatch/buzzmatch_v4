import 'package:cloud_firestore/cloud_firestore.dart';

class WalletModel {
  final String id;
  final String userId;
  final String userType; // 'brand' or 'creator'
  final double balance;
  final double pendingBalance;
  final double totalEarned;
  final double totalSpent;
  final DateTime createdAt;
  final DateTime updatedAt;

  WalletModel({
    required this.id,
    required this.userId,
    required this.userType,
    this.balance = 0.0,
    this.pendingBalance = 0.0,
    this.totalEarned = 0.0,
    this.totalSpent = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userType': userType,
      'balance': balance,
      'pendingBalance': pendingBalance,
      'totalEarned': totalEarned,
      'totalSpent': totalSpent,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory WalletModel.fromMap(Map<String, dynamic> map) {
    return WalletModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userType: map['userType'] ?? '',
      balance: map['balance']?.toDouble() ?? 0.0,
      pendingBalance: map['pendingBalance']?.toDouble() ?? 0.0,
      totalEarned: map['totalEarned']?.toDouble() ?? 0.0,
      totalSpent: map['totalSpent']?.toDouble() ?? 0.0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  factory WalletModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WalletModel.fromMap({
      'id': doc.id,
      ...data,
    });
  }

  WalletModel copyWith({
    String? id,
    String? userId,
    String? userType,
    double? balance,
    double? pendingBalance,
    double? totalEarned,
    double? totalSpent,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WalletModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userType: userType ?? this.userType,
      balance: balance ?? this.balance,
      pendingBalance: pendingBalance ?? this.pendingBalance,
      totalEarned: totalEarned ?? this.totalEarned,
      totalSpent: totalSpent ?? this.totalSpent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class TransactionModel {
  final String id;
  final String userId;
  final String userType; // 'brand' or 'creator'
  final String type; // 'deposit', 'withdrawal', 'payment', 'refund'
  final double amount;
  final String status; // 'pending', 'completed', 'failed', 'refunded'
  final String paymentMethod;
  final String? collaborationId;
  final String? campaignId;
  final String? description;
  final String? transactionReference;
  final DateTime createdAt;
  final DateTime? completedAt;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.userType,
    required this.type,
    required this.amount,
    required this.status,
    required this.paymentMethod,
    this.collaborationId,
    this.campaignId,
    this.description,
    this.transactionReference,
    required this.createdAt,
    this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userType': userType,
      'type': type,
      'amount': amount,
      'status': status,
      'paymentMethod': paymentMethod,
      'collaborationId': collaborationId,
      'campaignId': campaignId,
      'description': description,
      'transactionReference': transactionReference,
      'createdAt': createdAt,
      'completedAt': completedAt,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userType: map['userType'] ?? '',
      type: map['type'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      status: map['status'] ?? '',
      paymentMethod: map['paymentMethod'] ?? '',
      collaborationId: map['collaborationId'],
      campaignId: map['campaignId'],
      description: map['description'],
      transactionReference: map['transactionReference'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      completedAt: map['completedAt'] != null 
          ? (map['completedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel.fromMap({
      'id': doc.id,
      ...data,
    });
  }

  TransactionModel copyWith({
    String? id,
    String? userId,
    String? userType,
    String? type,
    double? amount,
    String? status,
    String? paymentMethod,
    String? collaborationId,
    String? campaignId,
    String? description,
    String? transactionReference,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userType: userType ?? this.userType,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      collaborationId: collaborationId ?? this.collaborationId,
      campaignId: campaignId ?? this.campaignId,
      description: description ?? this.description,
      transactionReference: transactionReference ?? this.transactionReference,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}