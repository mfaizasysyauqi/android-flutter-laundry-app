import 'package:dartz/dartz.dart';
import 'package:flutter_laundry_app/core/error/exceptions.dart';
import 'package:flutter_laundry_app/core/error/failures.dart';
import 'package:flutter_laundry_app/core/network/network_info.dart';
import 'package:flutter_laundry_app/data/datasources/remote/firebase_auth_remote_data_source.dart'
    as auth_ds;
import 'package:flutter_laundry_app/data/datasources/remote/user_remote_data_source.dart';
import 'package:flutter_laundry_app/domain/entities/user.dart';
import 'package:flutter_laundry_app/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final auth_ds.FirebaseAuthRemoteDataSource authRemoteDataSource;
  final UserRemoteDataSource userRemoteDataSource;
  final NetworkInfo networkInfo;

  UserRepositoryImpl({
    required this.authRemoteDataSource,
    required this.userRemoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, User>> getUser() async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = await authRemoteDataSource.getUser();
        return Right(userModel.toEntity());
      } on ServerException {
        return Left(ServerFailure());
      } on UserNotFoundException {
        return Left(UserNotFoundFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, User>> getUserById(String userId) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure());
      }
      final userModel = await userRemoteDataSource.getUserById(userId);
      return Right(userModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateLaundryPrice(
      int regulerPrice, int expressPrice) async {
    if (await networkInfo.isConnected) {
      try {
        final updatedUser = await userRemoteDataSource.updateLaundryPrice(
            regulerPrice, expressPrice);
        return Right(updatedUser.toEntity());
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, User>> getUserByUniqueName(String uniqueName) async {
    if (await networkInfo.isConnected) {
      try {
        final user = await userRemoteDataSource.getUserByUniqueName(uniqueName);
        return Right(user.toEntity());
      } catch (e) {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<User>>> getCustomers() async {
    if (await networkInfo.isConnected) {
      try {
        final userModels = await userRemoteDataSource.getCustomers();
        return Right(userModels.map((model) => model.toEntity()).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}
