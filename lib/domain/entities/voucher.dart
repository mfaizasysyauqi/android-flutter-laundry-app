import 'package:equatable/equatable.dart';

class Voucher extends Equatable {
  final String id;
  final String name;
  final double amount;
  final String type;
  final String obtainMethod;
  final DateTime? validityPeriod;
  final String laundryId; // New field
  final List<String> ownerVoucherIds; // New field

  const Voucher({
    required this.id,
    required this.name,
    required this.amount,
    required this.type,
    required this.obtainMethod,
    this.validityPeriod,
    required this.laundryId,
    required this.ownerVoucherIds,
  });

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
