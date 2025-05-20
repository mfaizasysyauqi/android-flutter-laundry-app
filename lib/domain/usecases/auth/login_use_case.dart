// File: lib/domain/usecases/auth/login_usecase.dart
// Berisi use case untuk menangani login pengguna.

// Mengimpor package dan file yang diperlukan.
import 'package:dartz/dartz.dart';
import '../../entities/user.dart';
import '../../../core/error/failures.dart';
import '../../repositories/auth_repository.dart';

// Kelas LoginUseCase untuk mengelola logika login.
class LoginUseCase {
  final AuthRepository repository;

  // Konstruktor yang menerima repository.
  LoginUseCase(this.repository);

  // Method untuk menjalankan login.
  Future<Either<Failure, User>> call({
    required String email,
    required String password,
  }) async {
    // Panggil method login dari repository.
    return await repository.login(
      email: email,
      password: password,
    );
  }
}