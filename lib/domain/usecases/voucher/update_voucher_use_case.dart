// File: lib/domain/usecases/voucher/update_voucher_usecase.dart
// Berisi use case untuk memperbarui voucher.

// Mengimpor package dan file yang diperlukan.
import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/voucher.dart';
import '../../repositories/voucher_repository.dart';

// Kelas UpdateVoucherUseCase untuk mengelola pembaruan voucher.
class UpdateVoucherUseCase {
  final VoucherRepository repository;

  // Konstruktor yang menerima repository.
  UpdateVoucherUseCase(this.repository);

  // Method untuk menjalankan pembaruan voucher.
  Future<Either<Failure, Voucher>> call(Voucher voucher) async {
    // Panggil method updateVoucher dari repository.
    return await repository.updateVoucher(voucher);
  }
}