import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/voucher.dart';

class VoucherModel extends Equatable {
  final String id;
  final String name;
  final double amount;
  final String type;
  final String obtainMethod;
  final DateTime? validityPeriod;
  final String laundryId;
  final List<String> ownerVoucherIds;

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
