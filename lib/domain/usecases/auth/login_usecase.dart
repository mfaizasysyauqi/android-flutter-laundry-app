import 'package:dartz/dartz.dart';
import 'package:flutter_laundry_app/domain/entities/user.dart';
import '../../../core/error/failures.dart';
import '../../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, User>> call({
    required String email,
    required String password,
  }) async {
    return await repository.login(
      email: email,
      password: password,
    );
  }
}
