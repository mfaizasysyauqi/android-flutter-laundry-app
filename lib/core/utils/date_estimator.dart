import 'package:tflite_flutter/tflite_flutter.dart';

class DateEstimator {
  static const String modelPath = 'assets/laundry_completion_model/laundry_completion_model.tflite';
  static const List<double> scalerMin = [5.0, 0.0, 0.0, 0.0, 5.0, 0.0];
  static const List<double> scalerMax = [100.0, 1.0, 15.0, 6.0, 100.0, 144.0];

  // Normalize input for the AI model
  static List<double> _normalizeInput(List<double> input) {
    if (input.length != scalerMin.length) {
      throw Exception('Input length (${input.length}) does not match expected length (${scalerMin.length})');
    }
    List<double> normalizedInput = [];
    for (int i = 0; i < input.length; i++) {
      double normalizedValue =
          (input[i] - scalerMin[i]) / (scalerMax[i] - scalerMin[i]);
      normalizedValue = normalizedValue.clamp(0.0, 1.0);
      normalizedInput.add(normalizedValue);
    }
    return normalizedInput;
  }

  // Non-AI method to calculate estimated completion time
  static DateTime calculateEstimatedCompletion(
      String laundrySpeed, double weight) {
    final now = DateTime.now();
    int additionalDays = 1; // Minimum 1 working day

    switch (laundrySpeed.toLowerCase()) {
      case 'express':
        additionalDays += (weight / 20).ceil() - 1;
        break;
      case 'reguler':
      default:
        additionalDays += (weight / 10).ceil() - 1;
        break;
    }

    DateTime estimatedDate = now;
    int daysAdded = 0;
    while (daysAdded < additionalDays) {
      estimatedDate = estimatedDate.add(const Duration(days: 1));
      if (estimatedDate.weekday <= 5) {
        daysAdded++; // Only count working days (Monday-Friday)
      }
    }
    return estimatedDate;
  }

  // AI method to calculate estimated completion time
  static Future<DateTime> calculateEstimatedCompletionWithAI(
    String laundrySpeed,
    double weight,
    double clothes,
    int queue,
    int weekday,
    double avgCompletionHours,
  ) async {
    if (weekday < 1 || weekday > 7) {
      throw Exception('Invalid weekday: $weekday. Must be between 1 and 7.');
    }

    final input = [
      weight.clamp(5.0, 100.0),
      laundrySpeed.toLowerCase() == 'express' ? 1.0 : 0.0,
      queue.toDouble().clamp(0.0, 15.0),
      (weekday - 1).toDouble(), // Normalize weekday (1-7 to 0-6)
      clothes.clamp(5.0, 100.0),
      avgCompletionHours.clamp(0.0, 144.0),
    ];

    final normalizedInput = _normalizeInput(input);

    final interpreter = await Interpreter.fromAsset(modelPath);
    final output = List.filled(1, List.filled(1, 0.0)).reshape([1, 1]);

    interpreter.run([normalizedInput], output);
    final predictedDays = output[0][0];

    interpreter.close();

    final predictedHours = (predictedDays * 24).toInt();
    if (predictedHours < 0) {
      throw Exception('Negative prediction from model: $predictedHours hours');
    }

    DateTime estimatedDate = DateTime.now();
    int hoursAdded = 0;
    while (hoursAdded < predictedHours) {
      estimatedDate = estimatedDate.add(const Duration(hours: 1));
      if (estimatedDate.weekday <= 5) {
        hoursAdded++; // Only count hours on working days
      }
    }

    return estimatedDate;
  }

  // Format date for output
  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:00';
  }
}