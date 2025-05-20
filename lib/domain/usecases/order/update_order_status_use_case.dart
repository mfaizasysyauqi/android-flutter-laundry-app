// File: lib/domain/usecases/user/update_laundry_price_usecase.dart
// Berisi use case untuk memperbarui harga laundry (reguler dan express) pengguna.

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

  // Method untuk menjalankan pembaruan harga laundry.
  Future<Either<Failure, User>> call(int regulerPrice, int expressPrice) async {
    // Validasi harga: pastikan harga reguler dan express positif.
    if (regulerPrice <= 0 || expressPrice <= 0) {
      return Left(ServerFailure(message: 'Harga harus lebih besar dari nol'));
    }

    // Panggil method updateLaundryPrice dari repository.
    return await repository.updateLaundryPrice(regulerPrice, expressPrice);
  }
}
