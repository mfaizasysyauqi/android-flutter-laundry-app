// File: lib/domain/usecases/user/get_user_by_id_usecase.dart
// Berisi use case untuk mendapatkan data pengguna berdasarkan ID.

// Mengimpor package dan file yang diperlukan.
import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/user.dart';
import '../../repositories/user_repository.dart';

// Kelas GetUserByIdUseCase untuk mengelola pengambilan data pengguna.
class GetUserByIdUseCase {
  final UserRepository repository;

  // Konstruktor yang menerima repository.
  GetUserByIdUseCase(this.repository);

  // Method untuk menjalankan pengambilan pengguna berdasarkan ID.
  Future<Either<Failure, User>> call(String userId) async {
    // Panggil method getUserById dari repository.
    return await repository.getUserById(userId);
  }
}