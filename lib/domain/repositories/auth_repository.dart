// File: lib/domain/repositories/auth_repository.dart
// Berisi interface AuthRepository untuk operasi autentikasi.

// Mengimpor package dan file yang diperlukan.
import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../../core/error/failures.dart';

// Abstrak kelas untuk mendefinisikan kontrak operasi autentikasi.
abstract class AuthRepository {
  // Method untuk mendaftarkan pengguna baru.
  Future<Either<Failure, User>> register({
    required String role,
    required String fullName,
    required String uniqueName,
    required String email,
    required String password,
    required String phoneNumber,
    required String address,
  });

  // Method untuk login pengguna.
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });
}