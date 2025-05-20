// File: lib/domain/repositories/order_repository.dart
// Berisi interface OrderRepository untuk operasi terkait pesanan.

// Mengimpor package dan file yang diperlukan.
import 'package:dartz/dartz.dart' as dartz;
import '../../core/error/failures.dart';
import '../entities/order.dart';

// Abstrak kelas untuk mendefinisikan kontrak operasi pesanan.
abstract class OrderRepository {
  // Method untuk membuat pesanan baru.
  Future<dartz.Either<Failure, void>> createOrder(Order order);
  // Method untuk mendapatkan semua pesanan.
  Future<dartz.Either<Failure, List<Order>>> getOrders();
  // Method untuk mendapatkan pesanan berdasarkan status.
  Future<dartz.Either<Failure, List<Order>>> getOrdersByStatus(String status);
  // Method untuk memperbarui status pesanan.
  Future<dartz.Either<Failure, Order>> updateOrderStatus(
      String orderId, String newStatus);
  // Method untuk memperbarui status dan waktu penyelesaian/pembatalan.
  Future<dartz.Either<Failure, void>> updateOrderStatusAndCompletion(
      String orderId, String newStatus);
  // Method untuk menghapus pesanan.
  Future<dartz.Either<Failure, void>> deleteOrder(String orderId);
  // Method untuk mendapatkan pesanan aktif.
  Future<List<Order>> getActiveOrders();
  // Method untuk mendapatkan pesanan berdasarkan ID pengguna atau laundry dan status.
  Future<dartz.Either<Failure, List<Order>>>
      getOrdersByUserIdOrLaundryIdAndStatus(String userId, String status);
  // Method untuk menandai pesanan sebagai riwayat.
  Future<dartz.Either<Failure, void>> setOrderAsHistory(String orderId);
  // Method untuk mendapatkan riwayat pesanan berdasarkan ID pengguna.
  Future<dartz.Either<Failure, List<Order>>> getHistoryOrdersByUserId(
      String userId);
}