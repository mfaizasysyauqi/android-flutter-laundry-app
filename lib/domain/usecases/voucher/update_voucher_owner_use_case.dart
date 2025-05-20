// Berisi use case untuk memperbarui pemilik voucher.

// Mengimpor package dan file yang diperlukan.
import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/voucher_repository.dart';

// Kelas UpdateVoucherOwnerUseCase untuk mengelola pembaruan pemilik voucher.
class UpdateVoucherOwnerUseCase {
  final VoucherRepository repository;

  // Konstruktor yang menerima repository.
  UpdateVoucherOwnerUseCase(this.repository);

  // Method untuk menjalankan pembaruan pemilik voucher.
  Future<Either<Failure, void>> call(String voucherId, String userId, bool add) async {
    // Panggil method updateVoucherOwner dari repository.
    return await repository.updateVoucherOwner(voucherId, userId, add);
  }
}