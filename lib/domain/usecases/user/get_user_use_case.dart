// File: lib/domain/usecases/user/get_user_usecase.dart
// Berisi use case untuk mendapatkan data pengguna saat ini.

// Mengimpor package dan file yang diperlukan.
import 'package:dartz/dartz.dart';
import '../../entities/user.dart';
import '../../repositories/user_repository.dart';
import '../../../core/error/failures.dart';

// Kelas GetUserUseCase untuk mengelola pengambilan data pengguna saat ini.
class GetUserUseCase {
  final UserRepository repository;

  // Konstruktor yang menerima repository.
  GetUserUseCase(this.repository);

  // Method untuk menjalankan pengambilan pengguna.
  Future<Either<Failure, User>> call() async {
    // Panggil method getUser dari repository.
    return await repository.getUser();
  }
}