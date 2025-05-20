// File: order_model.dart
// Berisi kelas OrderModel untuk merepresentasikan data pesanan dan menangani serialisasi/deserialisasi.

// Mengimpor package dan file yang diperlukan.
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import '../../domain/entities/order.dart';

// Kelas OrderModel yang memperluas entitas Order.
class OrderModel extends Order {
  // Konstruktor dengan parameter wajib dan opsional.
  const OrderModel({
    required super.id,
    required super.laundryUniqueName,
    required super.customerUniqueName,
    required super.clothes,
    required super.laundrySpeed,
    required super.vouchers,
    required super.weight,
    required super.status,
    required super.totalPrice,
    required super.createdAt,
    required super.estimatedCompletion,
    super.completedAt,
    super.cancelledAt,
    super.updatedAt,
    super.isHistory, // Menambahkan isHistory untuk menandai pesanan sebagai riwayat.
  });

  // Factory untuk membuat OrderModel dari JSON.
  factory OrderModel.fromJson(Map<String, dynamic> json, String id) {
    // Fungsi bantu untuk mengonversi timestamp ke DateTime.
    DateTime getDateTime(dynamic timestamp) {
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      } else if (timestamp is String) {
        return DateTime.parse(timestamp);
      }
      return DateTime.now();
    }

    // Tangani data clothes untuk menghitung jumlah pakaian.
    final clothesData = json['clothes'];
    final clothesCount =
        clothesData is List ? clothesData.length : (clothesData as int? ?? 0);

    return OrderModel(
      id: json['id'] as String? ?? '',
      laundryUniqueName: json['laundryUniqueName'] as String? ?? '',
      customerUniqueName: json['customerUniqueName'] as String? ?? '',
      clothes: clothesCount,
      laundrySpeed: json['laundrySpeed'] as String? ?? '',
      vouchers: List<String>.from(json['vouchers'] as List<dynamic>? ?? []),
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'pending',
      totalPrice: json['totalPrice'] as double? ?? 0,
      createdAt: getDateTime(json['createdAt']),
      estimatedCompletion: getDateTime(json['estimatedCompletion']),
      completedAt:
          json['completedAt'] != null ? getDateTime(json['completedAt']) : null,
      cancelledAt:
          json['cancelledAt'] != null ? getDateTime(json['cancelledAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? getDateTime(json['updatedAt']) : null,
      isHistory: json['isHistory'] as bool? ?? false, // Menangani isHistory.
    );
  }

  // Method untuk mengonversi OrderModel ke Map untuk Firestore.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'laundryUniqueName': laundryUniqueName,
      'customerUniqueName': customerUniqueName,
      'clothes': clothes,
      'laundrySpeed': laundrySpeed,
      'vouchers': vouchers,
      'weight': weight,
      'status': status,
      'totalPrice': totalPrice,
      'createdAt': Timestamp.fromDate(createdAt),
      'estimatedCompletion': Timestamp.fromDate(estimatedCompletion),
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'cancelledAt':
          cancelledAt != null ? Timestamp.fromDate(cancelledAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isHistory': isHistory, // Menambahkan isHistory ke Map.
    };
  }

  // Method untuk mengonversi OrderModel ke JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'laundryUniqueName': laundryUniqueName,
      'customerUniqueName': customerUniqueName,
      'clothes': clothes,
      'laundrySpeed': laundrySpeed,
      'vouchers': vouchers,
      'weight': weight,
      'status': status,
      'totalPrice': totalPrice,
      'createdAt': createdAt.toIso8601String(),
      'estimatedCompletion': estimatedCompletion.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isHistory': isHistory, // Menambahkan isHistory ke JSON.
    };
  }

  // Factory untuk membuat OrderModel dari entitas Order.
  factory OrderModel.fromEntity(Order order) {
    return OrderModel(
      id: order.id,
      laundryUniqueName: order.laundryUniqueName,
      customerUniqueName: order.customerUniqueName,
      clothes: order.clothes,
      laundrySpeed: order.laundrySpeed,
      vouchers: order.vouchers,
      weight: order.weight,
      status: order.status,
      totalPrice: order.totalPrice,
      createdAt: order.createdAt,
      estimatedCompletion: order.estimatedCompletion,
      completedAt: order.completedAt,
      cancelledAt: order.cancelledAt,
      updatedAt: order.updatedAt,
      isHistory: order.isHistory, // Menangani isHistory dari entitas.
    );
  }

  // Method untuk membuat salinan OrderModel dengan nilai baru.
  OrderModel copyWith({
    String? id,
    String? laundryUniqueName,
    String? customerUniqueName,
    int? clothes,
    String? laundrySpeed,
    List<String>? vouchers,
    double? weight,
    String? status,
    double? totalPrice,
    DateTime? createdAt,
    DateTime? estimatedCompletion,
    DateTime? completedAt,
    DateTime? cancelledAt,
    DateTime? updatedAt,
    bool? isHistory, // Menambahkan parameter isHistory.
  }) {
    return OrderModel(
      id: id ?? this.id,
      laundryUniqueName: laundryUniqueName ?? this.laundryUniqueName,
      customerUniqueName: customerUniqueName ?? this.customerUniqueName,
      clothes: clothes ?? this.clothes,
      laundrySpeed: laundrySpeed ?? this.laundrySpeed,
      vouchers: vouchers ?? this.vouchers,
      weight: weight ?? this.weight,
      status: status ?? this.status,
      totalPrice: totalPrice ?? this.totalPrice,
      createdAt: createdAt ?? this.createdAt,
      estimatedCompletion: estimatedCompletion ?? this.estimatedCompletion,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isHistory: isHistory ?? this.isHistory, // Menangani isHistory.
    );
  }

  // Override operator == untuk membandingkan dua OrderModel.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          laundryUniqueName == other.laundryUniqueName &&
          customerUniqueName == other.customerUniqueName &&
          clothes == other.clothes &&
          laundrySpeed == other.laundrySpeed &&
          vouchers == other.vouchers &&
          weight == other.weight &&
          status == other.status &&
          totalPrice == other.totalPrice &&
          createdAt == other.createdAt &&
          estimatedCompletion == other.estimatedCompletion &&
          completedAt == other.completedAt &&
          cancelledAt == other.cancelledAt &&
          updatedAt == other.updatedAt &&
          isHistory ==
              other.isHistory; // Menambahkan isHistory ke perbandingan.

  // Override hashCode untuk menghasilkan hash berdasarkan properti.
  @override
  int get hashCode => Object.hash(
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
        isHistory, // Menambahkan isHistory ke hash.
      );
}
