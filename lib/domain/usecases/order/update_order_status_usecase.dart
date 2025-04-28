// domain/usecases/user/update_laundry_price_usecase.dart
import 'package:dartz/dartz.dart';
import '../../entities/user.dart';
import '../../repositories/user_repository.dart';
import '../../../core/error/failures.dart';

class UpdateLaundryPriceUseCase {
  final UserRepository repository;

  UpdateLaundryPriceUseCase(this.repository);

  Future<Either<Failure, User>> call(int regulerPrice, int expressPrice) {
    return repository.updateLaundryPrice(regulerPrice, expressPrice);
  }
}
