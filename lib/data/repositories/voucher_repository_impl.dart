import 'package:dartz/dartz.dart';
import 'package:flutter_laundry_app/core/error/exceptions.dart';
import 'package:flutter_laundry_app/core/error/failures.dart';
import 'package:flutter_laundry_app/core/network/network_info.dart';
import 'package:flutter_laundry_app/data/datasources/remote/voucher_remote_data_source.dart';
import 'package:flutter_laundry_app/data/models/voucher_model.dart';
import 'package:flutter_laundry_app/domain/entities/voucher.dart';
import 'package:flutter_laundry_app/domain/repositories/voucher_repository.dart';

class VoucherRepositoryImpl implements VoucherRepository {
  final VoucherRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  VoucherRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Voucher>> createVoucher(Voucher voucher) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure());
      }
      final voucherModel = VoucherModel.fromEntity(voucher);
      final result = await remoteDataSource.createVoucher(voucherModel);
      return Right(result.toEntity());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Voucher>>> getVouchersByLaundryId(
      String laundryId) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure());
      }
      final voucherModels =
          await remoteDataSource.getVouchersByLaundryId(laundryId);
      final vouchers = voucherModels.map((model) => model.toEntity()).toList();
      return Right(vouchers);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Voucher>>> getVouchersByUserId() async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure());
      }
      final voucherModels = await remoteDataSource.getVouchersByUserId();
      final vouchers = voucherModels.map((model) => model.toEntity()).toList();
      return Right(vouchers);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Voucher>>> getVouchersForUserId(
      String userId) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure());
      }
      final voucherModels = await remoteDataSource.getVouchersForUserId(userId);
      final vouchers = voucherModels.map((model) => model.toEntity()).toList();
      return Right(vouchers);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Voucher>>> getVouchersByUserIdOrLaundryId(
    String? userId, {
    bool includeLaundry = false,
    bool includeOwner = true,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure());
      }
      final voucherModels =
          await remoteDataSource.getVouchersByUserIdOrLaundryId(
        userId,
        includeLaundry: includeLaundry,
        includeOwner: includeOwner,
      );
      final vouchers = voucherModels.map((model) => model.toEntity()).toList();
      return Right(vouchers);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateVoucherOwner(
      String voucherId, String userId, bool add) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure());
      }
      await remoteDataSource.updateVoucherOwner(voucherId, userId, add);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Voucher>> updateVoucher(Voucher voucher) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure());
      }
      final voucherModel = VoucherModel.fromEntity(voucher);
      final result = await remoteDataSource.updateVoucher(voucherModel);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteVoucher(String voucherId) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure());
      }
      await remoteDataSource.deleteVoucher(voucherId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Voucher>>> getVouchersByOwnerAndLaundryId(
      String ownerUserId, String laundryId) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure());
      }
      final voucherModels = await remoteDataSource
          .getVouchersByOwnerAndLaundryId(ownerUserId, laundryId);
      final vouchers = voucherModels.map((model) => model.toEntity()).toList();
      return Right(vouchers);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
