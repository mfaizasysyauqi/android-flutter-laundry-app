// File: lib/domain/usecases/voucher/get_vouchers_by_laundry_id_usecase.dart
// Ber фотisi use case untuk mendapatkan voucher berdasarkan ID laundry.

// Mengimpor package dan file yang diperlukan.
import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/voucher.dart';
import '../../repositories/voucher_repository.dart';

// Kelas GetVouchersByLaundryIdUseCase untuk mengelola pengambilan voucher.
class GetVouchersByLaundryIdUseCase {
  final VoucherRepository repository;

  // Konstruktor yang menerima repository.
  GetVouchersByLaundryIdUseCase(this.repository);

  // Method untuk menjalankan pengambilan voucher berdasarkan ID laundry.
  Future<Either<Failure, List<Voucher>>> call(String laundryId) async {
    // Panggil method getVouchersByLaundryId dari repository.
    return await repository.getVouchersByLaundryId(laundryId);
  }
}