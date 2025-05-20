// File: lib/domain/usecases/user/get_user_by_unique_name_usecase.dart
// Berisi use case untuk mendapatkan data pengguna berdasarkan nama unik.

// Mengimpor package dan file yang diperlukan.
import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/user.dart';
import '../../repositories/user_repository.dart';

// Kelas GetUserByUniqueNameUseCase untuk mengelola pengambilan pengguna berdasarkan nama unik.
class GetUserByUniqueNameUseCase {
  final UserRepository repository;

  // Konstruktor yang menerima repository abstrak (bukan implementasi).
  GetUserByUniqueNameUseCase(this.repository);

  // Method untuk menjalankan pengambilan pengguna.
  Future<Either<Failure, User>> call(String uniqueName) async {
    // Validasi nama unik: pastikan tidak kosong.
    if (uniqueName.trim().isEmpty) {
      return Left(ServerFailure(message: 'Nama unik tidak boleh kosong'));
    }

    // Panggil method getUserByUniqueName dari repository.
    return await repository.getUserByUniqueName(uniqueName);
  }
}