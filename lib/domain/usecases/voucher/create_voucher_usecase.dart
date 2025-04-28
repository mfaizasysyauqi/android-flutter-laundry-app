import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/voucher.dart';
import '../../repositories/voucher_repository.dart';

class CreateVoucherUseCase {
  final VoucherRepository repository;

  CreateVoucherUseCase(this.repository);

  Future<Either<Failure, Voucher>> call(Voucher voucher) async {
    return await repository.createVoucher(voucher);
  }
}
