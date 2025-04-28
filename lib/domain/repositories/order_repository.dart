import 'package:dartz/dartz.dart' as dartz;
import '../../core/error/failures.dart';
import '../entities/order.dart';

abstract class OrderRepository {
  Future<dartz.Either<Failure, void>> createOrder(Order order);
  Future<dartz.Either<Failure, List<Order>>> getOrders();
  Future<dartz.Either<Failure, List<Order>>> getOrdersByStatus(String status);
  Future<dartz.Either<Failure, Order>> updateOrderStatus(
      String orderId, String newStatus);
  Future<dartz.Either<Failure, void>> updateOrderStatusAndCompletion(
      String orderId, String newStatus);
  Future<dartz.Either<Failure, void>> deleteOrder(String orderId);
  Future<List<Order>> getActiveOrders();
  Future<dartz.Either<Failure, List<Order>>>
      getOrdersByUserIdOrLaundryIdAndStatus(String userId, String status);
  Future<dartz.Either<Failure, void>> setOrderAsHistory(String orderId);
  // New method for history orders
  Future<dartz.Either<Failure, List<Order>>> getHistoryOrdersByUserId(
      String userId);
}