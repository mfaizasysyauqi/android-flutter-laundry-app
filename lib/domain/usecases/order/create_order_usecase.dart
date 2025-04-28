// lib/domain/usecases/order/create_order_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_laundry_app/core/error/failures.dart';
import 'package:flutter_laundry_app/domain/repositories/order_repository.dart';
import 'package:flutter_laundry_app/domain/entities/order.dart' as entity;

class CreateOrderUseCase {
  final OrderRepository repository;

  CreateOrderUseCase(this.repository);

  Future<Either<Failure, void>> call(entity.Order order) async {
    return await repository.createOrder(order);
  }
}
