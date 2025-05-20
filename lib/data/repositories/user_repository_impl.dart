// File: user_repository_impl.dart
// Berisi implementasi UserRepository untuk menangani operasi pengguna dengan penanganan error.

// Mengimpor package dan file yang diperlukan.
import 'package:dartz/dartz.dart';
import 'package:flutter_laundry_app/core/error/exceptions.dart';
import 'package:flutter_laundry_app/core/error/failures.dart';
import 'package:flutter_laundry_app/core/network/network_info.dart';
import 'package:flutter_laundry_app/data/datasources/remote/firebase_auth_remote_data_source.dart'
    as auth_ds;
import 'package:flutter_laundry_app/data/datasources/remote/user_remote_data_source.dart';
import 'package:flutter_laundry_app/domain/entities/user.dart';
import 'package:flutter_laundry_app/domain/repositories/user_repository.dart';

// Implementasi dari UserRepository.
class UserRepositoryImpl implements UserRepository {
  // Properti untuk menyimpan data source dan network info.
  final auth_ds.FirebaseAuthRemoteDataSource authRemoteDataSource;
  final UserRemoteDataSource userRemoteDataSource;
  final NetworkInfo networkInfo;

  // Konstruktor yang menerima authRemoteDataSource, userRemoteDataSource, dan networkInfo.
  UserRepositoryImpl({
    required this.authRemoteDataSource,
    required this.userRemoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, User>> getUser() async {
    // Periksa koneksi jaringan.
    if (await networkInfo.isConnected) {
      try {
        // Ambil data pengguna melalui authRemoteDataSource.
        final userModel = await authRemoteDataSource.getUser();
        // Kembalikan entitas User sebagai Right.
        return Right(userModel.toEntity());
      } on ServerException {
        // Tangani error server.
        return Left(ServerFailure());
      } on UserNotFoundException {
        // Tangani error pengguna tidak ditemukan.
        return Left(UserNotFoundFailure());
      }
    } else {
      // Tangani kegagalan jaringan.
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, User>> getUserById(String userId) async {
    // Periksa koneksi jaringan.
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure());
      }
      // Ambil data pengguna berdasarkan ID melalui userRemoteDataSource.
      final userModel = await userRemoteDataSource.getUserById(userId);
      // Kembalikan entitas User sebagai Right.
      return Right(userModel.toEntity());
    } on ServerException catch (e) {
      // Tangani error server.
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      // Tangani error umum.
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateLaundryPrice(
      int regulerPrice, int expressPrice) async {
    // Periksa koneksi jaringan.
    if (await networkInfo.isConnected) {
      try {
        // Perbarui harga laundry melalui userRemoteDataSource.
        final updatedUser = await userRemoteDataSource.updateLaundryPrice(
            regulerPrice, expressPrice);
        // Kembalikan entitas User sebagai Right.
        return Right(updatedUser.toEntity());
      } on ServerException {
        // Tangani error server.
        return Left(ServerFailure());
      }
    } else {
      // Tangani kegagalan jaringan.
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, User>> getUserByUniqueName(String uniqueName) async {
    // Periksa koneksi jaringan.
    if (await networkInfo.isConnected) {
      try {
        // Ambil data pengguna berdasarkan uniqueName melalui userRemoteDataSource.
        final user = await userRemoteDataSource.getUserByUniqueName(uniqueName);
        // Kembalikan entitas User sebagai Right.
        return Right(user.toEntity());
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
  Future<Either<Failure, List<User>>> getCustomers() async {
    // Periksa koneksi jaringan.
    if (await networkInfo.isConnected) {
      try {
        // Ambil daftar pelanggan melalui userRemoteDataSource.
        final userModels = await userRemoteDataSource.getCustomers();
        // Konversi daftar UserModel ke daftar entitas User.
        return Right(userModels.map((model) => model.toEntity()).toList());
      } on ServerException catch (e) {
        // Tangani error server.
        return Left(ServerFailure(message: e.message));
      }
    } else {
      // Tangani kegagalan jaringan.
      return Left(NetworkFailure());
    }
  }
}