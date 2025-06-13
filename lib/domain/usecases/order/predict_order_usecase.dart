import 'package:flutter_laundry_app/core/utils/order_predictor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_laundry_app/presentation/providers/order_predictor_provider.dart';

class PredictOrderUseCase {
  final OrderPredictor predictor;

  PredictOrderUseCase(this.predictor);

  Future<double> predict(List<double> last7DaysOrders) async {
    return predictor.predict(last7DaysOrders);
  }
}

final predictOrderUseCaseProvider = Provider<PredictOrderUseCase>((ref) {
  final predictor = ref.watch(orderPredictorProvider);
  return PredictOrderUseCase(predictor);
});
