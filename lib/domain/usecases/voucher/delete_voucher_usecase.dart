import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/voucher_repository.dart';

class DeleteVoucherUseCase {
  final VoucherRepository repository;

  DeleteVoucherUseCase(this.repository);

  Future<Either<Failure, void>> call(String voucherId) async {
    return await repository.deleteVoucher(voucherId);
  }
}