// File: lib/domain/usecases/user/get_customers_usecase.dart
// Berisi use case untuk mendapatkan daftar pelanggan.

// Mengimpor package dan file yang diperlukan.
import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/user.dart';
import '../../repositories/user_repository.dart';

// Kelas GetCustomersUseCase untuk mengelola pengambilan daftar pelanggan.
class GetCustomersUseCase {
  final UserRepository repository;

  // Konstruktor yang menerima repository.
  GetCustomersUseCase(this.repository);

  // Method untuk menjalankan pengambilan pelanggan.
  Future<Either<Failure, List<User>>> call() async {
    // Panggil method getCustomers dari repository.
    return await repository.getCustomers();
  }
}