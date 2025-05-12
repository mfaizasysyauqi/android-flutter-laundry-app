import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/voucher.dart';
import '../../repositories/voucher_repository.dart';

class GetVouchersByUserIdUseCase {
  final VoucherRepository repository;

  GetVouchersByUserIdUseCase(this.repository);

  Future<Either<Failure, List<Voucher>>> call() async {
    return await repository.getVouchersByUserId();
  }
}
