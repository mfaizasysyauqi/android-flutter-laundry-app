// File: lib/domain/usecases/voucher/get_vouchers_by_owner_and_laundry_id_usecase.dart
// Berisi use case untuk mendapatkan voucher berdasarkan pemilik dan ID laundry.

// Mengimpor package dan file yang diperlukan.
import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/voucher.dart';
import '../../repositories/voucher_repository.dart';

// Kelas GetVouchersByOwnerAndLaundryIdUseCase untuk mengelola pengambilan voucher.
class GetVouchersByOwnerAndLaundryIdUseCase {
  final VoucherRepository repository;

  // Konstruktor yang menerima repository.
  GetVouchersByOwnerAndLaundryIdUseCase(this.repository);

  // Method untuk menjalankan pengambilan voucher.
  Future<Either<Failure, List<Voucher>>> call(
      String ownerUserId, String laundryId) async {
    // Panggil method getVouchersByOwnerAndLaundryId dari repository.
    return await repository.getVouchersByOwnerAndLaundryId(
        ownerUserId, laundryId);
  }
}
