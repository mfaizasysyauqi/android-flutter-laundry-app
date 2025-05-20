// File: lib/domain/repositories/voucher_repository.dart
// Berisi interface VoucherRepository untuk operasi terkait voucher.

// Mengimpor package dan file yang diperlukan.
import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/voucher.dart';

// Abstrak kelas untuk mendefinisikan kontrak operasi voucher.
abstract class VoucherRepository {
  // Method untuk membuat voucher baru.
  Future<Either<Failure, Voucher>> createVoucher(Voucher voucher);
  // Method untuk mendapatkan voucher berdasarkan ID laundry.
  Future<Either<Failure, List<Voucher>>> getVouchersByLaundryId(
      String laundryId);
  // Method untuk mendapatkan voucher berdasarkan ID pengguna.
  Future<Either<Failure, List<Voucher>>> getVouchersByUserId();
  // Method untuk mendapatkan voucher untuk ID pengguna tertentu.
  Future<Either<Failure, List<Voucher>>> getVouchersForUserId(String userId);
  // Method untuk mendapatkan voucher berdasarkan ID pengguna atau laundry.
  Future<Either<Failure, List<Voucher>>> getVouchersByUserIdOrLaundryId(
    String? userId, {
    bool includeLaundry = false,
    bool includeOwner = true,
  });
  // Method untuk memperbarui pemilik voucher.
  Future<Either<Failure, void>> updateVoucherOwner(
      String voucherId, String userId, bool add);
  // Method untuk memperbarui voucher.
  Future<Either<Failure, Voucher>> updateVoucher(Voucher voucher);
  // Method untuk menghapus voucher.
  Future<Either<Failure, void>> deleteVoucher(String voucherId);
  // Method untuk mendapatkan voucher berdasarkan pemilik dan ID laundry.
  Future<Either<Failure, List<Voucher>>> getVouchersByOwnerAndLaundryId(
      String ownerUserId, String laundryId);
}