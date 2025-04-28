import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/voucher.dart';

abstract class VoucherRepository {
  Future<Either<Failure, Voucher>> createVoucher(Voucher voucher);
  Future<Either<Failure, List<Voucher>>> getVouchersByLaundryId(
      String laundryId);
  Future<Either<Failure, List<Voucher>>> getVouchersByUserId();
  Future<Either<Failure, List<Voucher>>> getVouchersForUserId(String userId);
  Future<Either<Failure, List<Voucher>>> getVouchersByUserIdOrLaundryId(
    String? userId, {
    bool includeLaundry = false,
    bool includeOwner = true,
  });
  Future<Either<Failure, void>> updateVoucherOwner(
      String voucherId, String userId, bool add);
  Future<Either<Failure, Voucher>> updateVoucher(Voucher voucher);
  Future<Either<Failure, void>> deleteVoucher(String voucherId);
  Future<Either<Failure, List<Voucher>>> getVouchersByOwnerAndLaundryId(
      String ownerUserId, String laundryId);
}
