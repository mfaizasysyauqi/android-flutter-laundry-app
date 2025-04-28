import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_laundry_app/domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.id,
    required super.role,
    required super.fullName,
    required super.uniqueName,
    required super.email,
    required super.phoneNumber,
    required super.address,
    required super.regulerPrice,
    required super.expressPrice,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      role: json['role'],
      fullName: json['fullName'],
      uniqueName: json['uniqueName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      regulerPrice: json['regulerPrice'] ?? 7000,
      expressPrice: json['expressPrice'] ?? 10000,
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'])
          : (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'fullName': fullName,
      'uniqueName': uniqueName,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'regulerPrice': regulerPrice,
      'expressPrice': expressPrice,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  User toEntity() => User(
        id: id,
        role: role,
        fullName: fullName,
        uniqueName: uniqueName,
        email: email,
        phoneNumber: phoneNumber,
        address: address,
        regulerPrice: regulerPrice,
        expressPrice: expressPrice,
        createdAt: createdAt,
      );
}
