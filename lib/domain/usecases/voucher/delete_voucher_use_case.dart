// File: lib/domain/usecases/voucher/delete_voucher_usecase.dart
// Berisi use case untuk menghapus voucher.

// Mengimpor package dan file yang diperlukan.
import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/voucher_repository.dart';

// Kelas DeleteVoucherUseCase untuk mengelola penghapusan voucher.
class DeleteVoucherUseCase {
  final VoucherRepository repository;

  // Konstruktor yang menerima repository.
  DeleteVoucherUseCase(this.repository);

  // Method untuk menjalankan penghapusan voucher.
  Future<Either<Failure, void>> call(String voucherId) async {
    // Panggil method deleteVoucher dari repository.
    return await repository.deleteVoucher(voucherId);
  }
}