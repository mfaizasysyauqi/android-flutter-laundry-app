import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/voucher_repository.dart';

class UpdateVoucherOwnerUseCase {
  final VoucherRepository repository;

  UpdateVoucherOwnerUseCase(this.repository);

  Future<Either<Failure, void>> call(String voucherId, String userId, bool add) async {
    return await repository.updateVoucherOwner(voucherId, userId, add);
  }
}