// File: lib/domain/usecases/user/update_laundry_price_usecase.dart
// Berisi use case untuk memperbarui harga laundry.

// Mengimpor package dan file yang diperlukan.
import 'package:dartz/dartz.dart';
import '../../entities/user.dart';
import '../../repositories/user_repository.dart';
import '../../../core/error/failures.dart';

// Kelas UpdateLaundryPriceUseCase untuk mengelola pembaruan harga laundry.
class UpdateLaundryPriceUseCase {
  final UserRepository repository;

  // Konstruktor yang menerima repository.
  UpdateLaundryPriceUseCase(this.repository);

  // Method untuk menjalankan pembaruan harga.
  Future<Either<Failure, User>> call(int regulerPrice, int expressPrice) async {
    // Panggil method updateLaundryPrice dari repository.
    return await repository.updateLaundryPrice(regulerPrice, expressPrice);
  }
}