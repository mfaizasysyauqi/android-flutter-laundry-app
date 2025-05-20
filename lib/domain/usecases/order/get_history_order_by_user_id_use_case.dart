// File: lib/domain/usecases/order/get_history_orders_by_user_id_usecase.dart
// Berisi use case untuk mendapatkan riwayat pesanan berdasarkan ID pengguna.

// Mengimpor package dan file yang diperlukan.
import 'package:dartz/dartz.dart' as dartz;
import '../../../core/error/failures.dart';
import '../../entities/order.dart' as domain;
import '../../repositories/order_repository.dart';

// Kelas GetHistoryOrdersByUserIdUseCase untuk mengelola pengambilan riwayat pesanan.
class GetHistoryOrdersByUserIdUseCase {
  final OrderRepository repository;

  // Konstruktor yang menerima repository.
  GetHistoryOrdersByUserIdUseCase(this.repository);

  // Method untuk menjalankan pengambilan riwayat pesanan.
  Future<dartz.Either<Failure, List<domain.Order>>> call(String userId) async {
    // Panggil method getHistoryOrdersByUserId dari repository.
    return await repository.getHistoryOrdersByUserId(userId);
  }
}