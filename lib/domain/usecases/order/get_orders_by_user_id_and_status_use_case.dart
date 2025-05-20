// File: lib/domain/usecases/order/get_orders_by_user_id_or_laundry_id_and_status_usecase.dart
// Berisi use case untuk mendapatkan pesanan berdasarkan ID pengguna atau laundry dan status.

// Mengimpor package dan file yang diperlukan.
import 'package:dartz/dartz.dart' as dartz;
import '../../../core/error/failures.dart';
import '../../entities/order.dart' as domain;
import '../../repositories/order_repository.dart';

// Kelas GetOrdersByUserIdOrLaundryIdAndStatusUseCase untuk mengelola pengambilan pesanan.
class GetOrdersByUserIdOrLaundryIdAndStatusUseCase {
  final OrderRepository repository;

  // Konstruktor yang menerima repository.
  GetOrdersByUserIdOrLaundryIdAndStatusUseCase(this.repository);

  // Method untuk menjalankan pengambilan pesanan.
  Future<dartz.Either<Failure, List<domain.Order>>> call(
      String userId, String status) async {
    // Panggil method getOrdersByUserIdOrLaundryIdAndStatus dari repository.
    return await repository.getOrdersByUserIdOrLaundryIdAndStatus(
        userId, status);
  }
}