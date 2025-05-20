// File: auth_repository_impl.dart
// Berisi implementasi AuthRepository untuk menangani operasi autentikasi dengan penanganan error.

// Mengimpor package dan file yang diperlukan.
import 'package:dartz/dartz.dart';
import 'package:flutter_laundry_app/domain/entities/user.dart';
import 'package:flutter_laundry_app/domain/repositories/auth_repository.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../datasources/remote/firebase_auth_remote_data_source.dart';

// Implementasi dari AuthRepository.
class AuthRepositoryImpl implements AuthRepository {
  // Properti untuk menyimpan data source dan network info.
  final FirebaseAuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  // Konstruktor yang menerima remoteDataSource dan networkInfo.
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, User>> register({
    required String role,
    required String fullName,
    required String uniqueName,
    required String email,
    required String password,
    required String phoneNumber,
    required String address,
  }) async {
    // Periksa koneksi jaringan.
    if (await networkInfo.isConnected) {
      try {
        // Lakukan registrasi melalui remoteDataSource.
        final userModel = await remoteDataSource.register(
          role: role,
          fullName: fullName,
          uniqueName: uniqueName,
          email: email,
          password: password,
          phoneNumber: phoneNumber,
          address: address,
        );
        // Kembalikan hasil sukses sebagai Right.
        return Right(userModel);
      } on ServerException {
        // Tangani error server.
        return Left(ServerFailure());
      } on WeakPasswordException {
        // Tangani error kata sandi lemah.
        return Left(WeakPasswordFailure());
      } on EmailAlreadyInUseException {
        // Tangani error email sudah digunakan.
        return Left(EmailAlreadyInUseFailure());
      } on UniqueNameAlreadyInUseException {
        // Tangani error nama unik sudah digunakan.
        return Left(UniqueNameAlreadyInUseFailure());
      } catch (e) {
        // Tangani error umum.
        return Left(ServerFailure());
      }
    } else {
      // Tangani kegagalan jaringan.
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    // Periksa koneksi jaringan.
    if (await networkInfo.isConnected) {
      try {
        // Lakukan login melalui remoteDataSource.
        final userModel = await remoteDataSource.login(
          email: email,
          password: password,
        );
        // Kembalikan hasil sukses sebagai Right.
        return Right(userModel);
      } on ServerException {
        // Tangani error server.
        return Left(ServerFailure());
      } on EmailNotFoundException {
        // Tangani error email tidak ditemukan.
        return Left(EmailNotFoundFailure());
      } on WrongPasswordException {
        // Tangani error kata sandi salah.
        return Left(WrongPasswordFailure());
      } on InvalidCredentialsException {
        // Tangani error kredensial tidak valid.
        return Left(InvalidCredentialsFailure());
      } on UserNotFoundException {
        // Tangani error pengguna tidak ditemukan.
        return Left(UserNotFoundFailure());
      } catch (e) {
        // Tangani error umum.
        return Left(ServerFailure());
      }
    } else {
      // Tangani kegagalan jaringan.
      return Left(NetworkFailure());
    }
  }
}
