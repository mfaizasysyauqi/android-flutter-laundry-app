// File: lib/domain/usecases/voucher/get_vouchers_by_user_id_usecase.dart
// Berisi use case untuk mendapatkan voucher berdasarkan ID pengguna.

// Mengimpor package dan file yang diperlukan.
import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/voucher.dart';
import '../../repositories/voucher_repository.dart';

// Kelas GetVouchersByUserIdUseCase untuk mengelola pengambilan voucher.
class GetVouchersByUserIdUseCase {
  final VoucherRepository repository;

  // Konstruktor yang menerima repository.
  GetVouchersByUserIdUseCase(this.repository);

  // Method untuk menjalankan pengambilan voucher.
  Future<Either<Failure, List<Voucher>>> call() async {
    // Panggil method getVouchersByUserId dari repository.
    return await repository.getVouchersByUserId();
  }
}