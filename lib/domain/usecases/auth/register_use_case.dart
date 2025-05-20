// Mengimpor package dan file yang diperlukan.
import 'package:dartz/dartz.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';
import '../../../core/error/failures.dart';

// Kelas RegisterUseCase untuk mengelola logika registrasi.
class RegisterUseCase {
  final AuthRepository repository;

  // Konstruktor yang menerima repository.
  RegisterUseCase(this.repository);

  // Method untuk menjalankan registrasi.
  Future<Either<Failure, User>> call({
    required String role,
    required String fullName,
    required String uniqueName,
    required String email,
    required String password,
    required String phoneNumber,
    required String address,
  }) async {
    // Panggil method register dari repository.
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