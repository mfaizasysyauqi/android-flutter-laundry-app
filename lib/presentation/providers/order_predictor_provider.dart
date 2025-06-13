import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_laundry_app/core/utils/order_predictor.dart';

final orderPredictorProvider = Provider<OrderPredictor>((ref) {
  final predictor = OrderPredictor();
  predictor.loadModel();
  ref.onDispose(() => predictor.dispose());
  return predictor;
});
