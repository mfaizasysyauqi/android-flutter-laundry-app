import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/voucher.dart';
import '../../repositories/voucher_repository.dart';

class GetVouchersByOwnerAndLaundryIdUseCase {
  final VoucherRepository repository;

  GetVouchersByOwnerAndLaundryIdUseCase(this.repository);

  Future<Either<Failure, List<Voucher>>> call(
      String ownerUserId, String laundryId) async {
    return await repository.getVouchersByOwnerAndLaundryId(
        ownerUserId, laundryId);
  }
}