// File: lib/domain/repositories/user_repository.dart
// Berisi interface UserRepository untuk operasi terkait pengguna.

// Mengimpor package dan file yang diperlukan.
import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../../../core/error/failures.dart';

// Abstrak kelas untuk mendefinisikan kontrak operasi pengguna.
abstract class UserRepository {
  // Method untuk mendapatkan data pengguna saat ini.
  Future<Either<Failure, User>> getUser();
  // Method untuk mendapatkan data pengguna berdasarkan ID.
  Future<Either<Failure, User>> getUserById(String userId);
  // Method untuk memperbarui harga laundry.
  Future<Either<Failure, User>> updateLaundryPrice(
      int regulerPrice, int expressPrice);
  // Method untuk mendapatkan pengguna berdasarkan nama unik.
  Future<Either<Failure, User>> getUserByUniqueName(String uniqueName);
  // Method untuk mendapatkan daftar pelanggan.
  Future<Either<Failure, List<User>>> getCustomers();
}