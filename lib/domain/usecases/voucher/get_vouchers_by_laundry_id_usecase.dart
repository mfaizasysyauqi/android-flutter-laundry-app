import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/voucher.dart';
import '../../repositories/voucher_repository.dart';

class GetVouchersByLaundryIdUseCase {
  final VoucherRepository repository;

  GetVouchersByLaundryIdUseCase(this.repository);

  Future<Either<Failure, List<Voucher>>> call(String laundryId) async {
    return await repository.getVouchersByLaundryId(laundryId);
  }
}
