import 'package:dartz/dartz.dart' as dartz;
import '../../../core/error/failures.dart';
import '../../entities/order.dart' as domain;
import '../../repositories/order_repository.dart';

class GetOrdersByUserIdOrLaundryIdAndStatusUseCase {
  final OrderRepository repository;

  GetOrdersByUserIdOrLaundryIdAndStatusUseCase(this.repository);

  Future<dartz.Either<Failure, List<domain.Order>>> call(
      String userId, String status) async {
    return await repository.getOrdersByUserIdOrLaundryIdAndStatus(
        userId, status);
  }
}