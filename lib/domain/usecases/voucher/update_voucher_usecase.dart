import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/voucher.dart';
import '../../repositories/voucher_repository.dart';

class UpdateVoucherUseCase {
  final VoucherRepository repository;

  UpdateVoucherUseCase(this.repository);

  Future<Either<Failure, Voucher>> call(Voucher voucher) async {
    return await repository.updateVoucher(voucher);
  }
}