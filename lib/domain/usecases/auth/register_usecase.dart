import 'package:dartz/dartz.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';
import '../../../core/error/failures.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, User>> call({
    required String role,
    required String fullName,
    required String uniqueName,
    required String email,
    required String password,
    required String phoneNumber,
    required String address,
  }) async {
    return await repository.register(
      role: role,
      fullName: fullName,
      uniqueName: uniqueName,
      email: email,
      password: password,
      phoneNumber: phoneNumber,
      address: address,
    );
  }
}
