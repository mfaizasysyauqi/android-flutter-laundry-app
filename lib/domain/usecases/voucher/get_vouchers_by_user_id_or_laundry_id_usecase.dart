import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/voucher.dart';
import '../../repositories/voucher_repository.dart';

class GetVouchersByUserIdOrLaundryIdUseCase {
  final VoucherRepository repository;

  GetVouchersByUserIdOrLaundryIdUseCase(this.repository);

  Future<Either<Failure, List<Voucher>>> call({
    String? userId,
    bool includeLaundry = false,
    bool includeOwner = true,
  }) async {
    return await repository.getVouchersByUserIdOrLaundryId(
      userId,
      includeLaundry: includeLaundry,
      includeOwner: includeOwner,
    );
  }
}
