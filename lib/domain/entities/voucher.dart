// File: lib/domain/entities/voucher.dart
// Berisi kelas Voucher untuk merepresentasikan entitas voucher dalam domain layer.

// Mengimpor package yang diperlukan.
import 'package:equatable/equatable.dart';

// Kelas Voucher yang memperluas Equatable untuk perbandingan objek.
class Voucher extends Equatable {
  // Properti untuk menyimpan data voucher.
  final String id;
  final String name;
  final double amount;
  final String type;
  final String obtainMethod;
  final DateTime? validityPeriod;
  final String laundryId; // ID laundry yang terkait dengan voucher.
  final List<String> ownerVoucherIds; // Daftar ID pengguna yang memiliki voucher.

  // Konstruktor dengan parameter wajib dan opsional.
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

  // Override props untuk Equatable, digunakan untuk perbandingan.
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