import 'package:dartz/dartz.dart';
import 'package:flutter_laundry_app/core/error/failures.dart';
import 'package:flutter_laundry_app/data/repositories/user_repository_impl.dart';
import 'package:flutter_laundry_app/domain/entities/user.dart';

class GetUserByUniqueNameUseCase {
  final UserRepositoryImpl repository;

  GetUserByUniqueNameUseCase(this.repository);

  Future<Either<Failure, User>> call(String uniqueName) async {
    return await repository.getUserByUniqueName(uniqueName);
  }
}
