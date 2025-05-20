// File: lib/domain/usecases/order/create_order_usecase.dart
// Berisi use case untuk membuat pesanan baru.

// Mengimpor package dan file yang diperlukan.
import 'package:dartz/dartz.dart';
import 'package:flutter_laundry_app/core/error/failures.dart';
import 'package:flutter_laundry_app/domain/repositories/order_repository.dart';
import 'package:flutter_laundry_app/domain/entities/order.dart' as entity;

// Kelas CreateOrderUseCase untuk mengelola pembuatan pesanan.
class CreateOrderUseCase {
  final OrderRepository repository;

  // Konstruktor yang menerima repository.
  CreateOrderUseCase(this.repository);

  // Method untuk menjalankan pembuatan pesanan.
  Future<Either<Failure, void>> call(entity.Order order) async {
    // Panggil method createOrder dari repository.
    return await repository.createOrder(order);
  }
}