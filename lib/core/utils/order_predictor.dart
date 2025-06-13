import 'package:tflite_flutter/tflite_flutter.dart';

class OrderPredictor {
  late Interpreter _interpreter;

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset(
        'assets/laundry_predict_model/order_predictor_modelfix.tflite');
  }

  Future<double> predict(List<double> inputData) async {
    if (inputData.length != 7) {
      throw Exception("Input harus 7 elemen");
    }

    final input = [inputData];
    final output = List.generate(1, (_) => List.filled(1, 0.0));
    _interpreter.run(input, output);

    return output[0][0];
  }

  void dispose() {
    _interpreter.close();
  }
}
