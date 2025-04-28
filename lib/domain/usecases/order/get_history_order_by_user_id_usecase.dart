import 'package:dartz/dartz.dart' as dartz;
import '../../../core/error/failures.dart';
import '../../entities/order.dart' as domain;
import '../../repositories/order_repository.dart';

class GetHistoryOrdersByUserIdUseCase {
  final OrderRepository repository;

  GetHistoryOrdersByUserIdUseCase(this.repository);

  Future<dartz.Either<Failure, List<domain.Order>>> call(String userId) async {
    return await repository.getHistoryOrdersByUserId(userId);
  }
}