import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/user.dart';
import '../../repositories/user_repository.dart';

class GetCustomersUseCase {
  final UserRepository repository;

  GetCustomersUseCase(this.repository);

  Future<Either<Failure, List<User>>> call() async {
    return await repository.getCustomers();
  }
}