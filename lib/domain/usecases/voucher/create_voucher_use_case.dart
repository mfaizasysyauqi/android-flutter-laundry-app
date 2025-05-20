// File: lib/domain/usecases/voucher/create_voucher_usecase.dart
// Berisi use case untuk membuat voucher baru.

// Mengimpor package dan file yang diperlukan.
import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/voucher.dart';
import '../../repositories/voucher_repository.dart';

// Kelas CreateVoucherUseCase untuk mengelola pembuatan voucher.
class CreateVoucherUseCase {
  final VoucherRepository repository;

  // Konstruktor yang menerima repository.
  CreateVoucherUseCase(this.repository);

  // Method untuk menjalankan pembuatan voucher.
  Future<Either<Failure, Voucher>> call(Voucher voucher) async {
    // Panggil method createVoucher dari repository.
    return await repository.createVoucher(voucher);
  }
}