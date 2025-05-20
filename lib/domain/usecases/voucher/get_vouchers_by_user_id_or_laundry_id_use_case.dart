// File: lib/domain/usecases/voucher/get_vouchers_by_user_id_or_laundry_id_usecase.dart
// Berisi use case untuk mendapatkan voucher berdasarkan ID pengguna atau laundry.

// Mengimpor package dan file yang diperlukan.
import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/voucher.dart';
import '../../repositories/voucher_repository.dart';

// Kelas GetVouchersByUserIdOrLaundryIdUseCase untuk mengelola pengambilan voucher.
class GetVouchersByUserIdOrLaundryIdUseCase {
  final VoucherRepository repository;

  // Konstruktor yang menerima repository.
  GetVouchersByUserIdOrLaundryIdUseCase(this.repository);

  // Method untuk menjalankan pengambilan voucher.
  Future<Either<Failure, List<Voucher>>> call({
    String? userId,
    bool includeLaundry = false,
    bool includeOwner = true,
  }) async {
    // Panggil method getVouchersByUserIdOrLaundryId dari repository.
    return await repository.getVouchersByUserIdOrLaundryId(
      userId,
      includeLaundry: includeLaundry,
      includeOwner: includeOwner,
    );
  }
}