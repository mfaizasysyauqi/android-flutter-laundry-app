// File: voucher_repository_impl.dart
// Berisi implementasi VoucherRepository untuk menangani operasi voucher dengan penanganan error dan pemeriksaan jaringan.

// Mengimpor package dan file yang diperlukan.
import 'package:dartz/dartz.dart';
import 'package:flutter_laundry_app/core/error/exceptions.dart';
import 'package:flutter_laundry_app/core/error/failures.dart';
import 'package:flutter_laundry_app/core/network/network_info.dart';
import 'package:flutter_laundry_app/data/datasources/remote/voucher_remote_data_source.dart';
import 'package:flutter_laundry_app/data/models/voucher_model.dart';
import 'package:flutter_laundry_app/domain/entities/voucher.dart';
import 'package:flutter_laundry_app/domain/repositories/voucher_repository.dart';

// Implementasi dari VoucherRepository.
class VoucherRepositoryImpl implements VoucherRepository {
  // Properti untuk menyimpan remoteDataSource dan networkInfo.
  final VoucherRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  // Konstruktor yang menerima remoteDataSource dan networkInfo.
  VoucherRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Voucher>> createVoucher(Voucher voucher) async {
    // Periksa koneksi jaringan.
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure());
      }
      // Buat VoucherModel dari entitas Voucher.
      final voucherModel = VoucherModel.fromEntity(voucher);
      // Buat voucher melalui remoteDataSource.
      final result = await remoteDataSource.createVoucher(voucherModel);
      // Kembalikan entitas Voucher sebagai Right.
      return Right(result.toEntity());
    } on ServerException {
      // Tangani error server.
      return Left(ServerFailure());
    } catch (e) {
      // Tangani error umum.
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Voucher>>> getVouchersByLaundryId(
      String laundryId) async {
    // Periksa koneksi jaringan.
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure());
      }
      // Ambil voucher berdasarkan laundryId melalui remoteDataSource.
      final voucherModels =
          await remoteDataSource.getVouchersByLaundryId(laundryId);
      // Konversi daftar VoucherModel ke daftar entitas Voucher.
      final vouchers = voucherModels.map((model) => model.toEntity()).toList();
      // Kembalikan hasil sukses sebagai Right.
      return Right(vouchers);
    } on ServerException {
      // Tangani error server.
      return Left(ServerFailure());
    } catch (e) {
      // Tangani error umum.
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Voucher>>> getVouchersByUserId() async {
    // Periksa koneksi jaringan.
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure());
      }
      // Ambil voucher berdasarkan userId melalui remoteDataSource.
      final voucherModels = await remoteDataSource.getVouchersByUserId();
      // Konversi daftar VoucherModel ke daftar entitas Voucher.
      final vouchers = voucherModels.map((model) => model.toEntity()).toList();
      // Kembalikan hasil sukses sebagai Right.
      return Right(vouchers);
    } on ServerException {
      // Tangani error server.
      return Left(ServerFailure());
    } catch (e) {
      // Tangani error umum.
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Voucher>>> getVouchersForUserId(
      String userId) async {
    // Periksa koneksi jaringan.
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure());
      }
      // Ambil voucher untuk userId tertentu melalui remoteDataSource.
      final voucherModels = await remoteDataSource.getVouchersForUserId(userId);
      // Konversi daftar VoucherModel ke daftar entitas Voucher.
      final vouchers = voucherModels.map((model) => model.toEntity()).toList();
      // Kembalikan hasil sukses sebagai Right.
      return Right(vouchers);
    } on ServerException {
      // Tangani error server.
      return Left(ServerFailure());
    } catch (e) {
      // Tangani error umum.
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Voucher>>> getVouchersByUserIdOrLaundryId(
    String? userId, {
    bool includeLaundry = false,
    bool includeOwner = true,
  }) async {
    // Periksa koneksi jaringan.
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure());
      }
      // Ambil voucher berdasarkan userId atau laundryId melalui remoteDataSource.
      final voucherModels =
          await remoteDataSource.getVouchersByUserIdOrLaundryId(
        userId,
        includeLaundry: includeLaundry,
        includeOwner: includeOwner,
      );
      // Konversi daftar VoucherModel ke daftar entitas Voucher.
      final vouchers = voucherModels.map((model) => model.toEntity()).toList();
      // Kembalikan hasil sukses sebagai Right.
      return Right(vouchers);
    } on ServerException {
      // Tangani error server.
      return Left(ServerFailure());
    } catch (e) {
      // Tangani error umum.
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateVoucherOwner(
      String voucherId, String userId, bool add) async {
    // Periksa koneksi jaringan.
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure());
      }
      // Perbarui pemilik voucher melalui remoteDataSource.
      await remoteDataSource.updateVoucherOwner(voucherId, userId, add);
      // Kembalikan hasil sukses sebagai Right.
      return const Right(null);
    } on ServerException catch (e) {
      // Tangani error server.
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      // Tangani error umum.
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Voucher>> updateVoucher(Voucher voucher) async {
    // Periksa koneksi jaringan.
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure());
      }
      // Buat VoucherModel dari entitas Voucher.
      final voucherModel = VoucherModel.fromEntity(voucher);
      // Perbarui voucher melalui remoteDataSource.
      final result = await remoteDataSource.updateVoucher(voucherModel);
      // Kembalikan entitas Voucher sebagai Right.
      return Right(result.toEntity());
    } on ServerException catch (e) {
      // Tangani error server.
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      // Tangani error umum.
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteVoucher(String voucherId) async {
    // Periksa koneksi jaringan.
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure());
      }
      // Hapus voucher melalui remoteDataSource.
      await remoteDataSource.deleteVoucher(voucherId);
      // Kembalikan hasil sukses sebagai Right.
      return const Right(null);
    } on ServerException catch (e) {
      // Tangani error server.
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      // Tangani error umum.
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Voucher>>> getVouchersByOwnerAndLaundryId(
      String ownerUserId, String laundryId) async {
    // Periksa koneksi jaringan.
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure());
      }
      // Ambil voucher berdasarkan ownerUserId dan laundryId melalui remoteDataSource.
      final voucherModels = await remoteDataSource
          .getVouchersByOwnerAndLaundryId(ownerUserId, laundryId);
      // Konversi daftar VoucherModel ke daftar entitas Voucher.
      final vouchers = voucherModels.map((model) => model.toEntity()).toList();
      // Kembalikan hasil sukses sebagai Right.
      return Right(vouchers);
    } on ServerException {
      // Tangani error server.
      return Left(ServerFailure());
    } catch (e) {
      // Tangani error umum.
      return Left(ServerFailure());
    }
  }
}
