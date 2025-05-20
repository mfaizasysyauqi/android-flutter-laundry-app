// File: lib/domain/entities/order.dart
// Berisi kelas Order untuk merepresentasikan entitas pesanan dalam domain layer.

// Mengimpor package yang diperlukan.
import 'package:equatable/equatable.dart';

// Kelas Order yang memperluas Equatable untuk perbandingan objek.
class Order extends Equatable {
  // Properti untuk menyimpan data pesanan.
  final String id;
  final String laundryUniqueName;
  final String customerUniqueName;
  final int clothes;
  final String laundrySpeed;
  final List<String> vouchers;
  final double weight;
  final String status;
  final double totalPrice;
  final DateTime createdAt;
  final DateTime estimatedCompletion;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final DateTime? updatedAt;
  final bool isHistory; // Menandakan apakah pesanan masuk riwayat.

  // Konstruktor dengan parameter wajib dan opsional.
  const Order({
    required this.id,
    required this.laundryUniqueName,
    required this.customerUniqueName,
    required this.clothes,
    required this.laundrySpeed,
    required this.vouchers,
    required this.weight,
    required this.status,
    required this.totalPrice,
    required this.createdAt,
    required this.estimatedCompletion,
    this.completedAt,
    this.cancelledAt,
    this.updatedAt,
    this.isHistory = false, // Default ke false.
  });

  // Override props untuk Equatable, digunakan untuk perbandingan.
  @override
  List<Object?> get props => [
        id,
        laundryUniqueName,
        customerUniqueName,
        clothes,
        laundrySpeed,
        vouchers,
        weight,
        status,
        totalPrice,
        createdAt,
        estimatedCompletion,
        completedAt,
        cancelledAt,
        updatedAt,
        isHistory,
      ];
}
