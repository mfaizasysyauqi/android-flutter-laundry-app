import 'package:dartz/dartz.dart';
import 'package:flutter_laundry_app/domain/entities/user.dart';
import 'package:flutter_laundry_app/domain/repositories/auth_repository.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../datasources/remote/firebase_auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

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
    if (await networkInfo.isConnected) {
      try {
        final userModel = await remoteDataSource.register(
          role: role,
          fullName: fullName,
          uniqueName: uniqueName,
          email: email,
          password: password,
          phoneNumber: phoneNumber,
          address: address,
        );
        return Right(userModel);
      } on ServerException {
        return Left(ServerFailure());
      } on WeakPasswordException {
        return Left(WeakPasswordFailure());
      } on EmailAlreadyInUseException {
        return Left(EmailAlreadyInUseFailure());
      } on UniqueNameAlreadyInUseException {
        return Left(UniqueNameAlreadyInUseFailure());
      } catch (e) {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = await remoteDataSource.login(
          email: email,
          password: password,
        );
        return Right(userModel);
      } on ServerException {
        return Left(ServerFailure());
      } on EmailNotFoundException {
        return Left(EmailNotFoundFailure());
      } on WrongPasswordException {
        return Left(WrongPasswordFailure());
      } on InvalidCredentialsException {
        return Left(InvalidCredentialsFailure());
      } on UserNotFoundException {
        return Left(UserNotFoundFailure());
      } catch (e) {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}
