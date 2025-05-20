// File: voucher_model.dart
// Berisi kelas VoucherModel untuk merepresentasikan data voucher dan menangani serialisasi/deserialisasi.

// Mengimpor package dan file yang diperlukan.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/voucher.dart';

// Kelas VoucherModel yang memperluas Equatable untuk perbandingan.
class VoucherModel extends Equatable {
  // Properti untuk menyimpan data voucher.
  final String id;
  final String name;
  final double amount;
  final String type;
  final String obtainMethod;
  final DateTime? validityPeriod;
  final String laundryId;
  final List<String> ownerVoucherIds;

  // Konstruktor dengan parameter wajib dan opsional.
  const VoucherModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.type,
    required this.obtainMethod,
    this.validityPeriod,
    required this.laundryId,
    required this.ownerVoucherIds,
  });

  // Factory untuk membuat VoucherModel dari entitas Voucher.
  factory VoucherModel.fromEntity(Voucher voucher) => VoucherModel(
        id: voucher.id,
        name: voucher.name,
        amount: voucher.amount,
        type: voucher.type,
        obtainMethod: voucher.obtainMethod,
        validityPeriod: voucher.validityPeriod,
        laundryId: voucher.laundryId,
        ownerVoucherIds: voucher.ownerVoucherIds,
      );

  // Method untuk mengonversi VoucherModel ke entitas Voucher.
  Voucher toEntity() => Voucher(
        id: id,
        name: name,
        amount: amount,
        type: type,
        obtainMethod: obtainMethod,
        validityPeriod: validityPeriod,
        laundryId: laundryId,
        ownerVoucherIds: ownerVoucherIds,
      );

  // Method untuk mengonversi VoucherModel ke Map untuk Firestore.
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'amount': amount,
        'type': type,
        'obtainMethod': obtainMethod,
        'validityPeriod':
            validityPeriod != null ? Timestamp.fromDate(validityPeriod!) : null,
        'laundryId': laundryId,
        'ownerVoucherIds': ownerVoucherIds,
      };

  // Factory untuk membuat VoucherModel dari JSON.
  factory VoucherModel.fromJson(Map<String, dynamic> data, String id) =>
      VoucherModel(
        id: id,
        name: data['name'] as String,
        amount: (data['amount'] as num).toDouble(),
        type: data['type'] as String,
        obtainMethod: data['obtainMethod'] as String,
        validityPeriod: data['validityPeriod'] != null
            ? (data['validityPeriod'] as Timestamp).toDate()
            : null,
        laundryId: data['laundryId'] as String,
        ownerVoucherIds: List<String>.from(data['ownerVoucherIds'] ?? []),
      );

  // Override properti props untuk Equatable.
  @override
  List<Object?> get props => [
        id,
        name,
        amount,
        type,
        obtainMethod,
        validityPeriod,
        laundryId,
        ownerVoucherIds,
      ];
}
