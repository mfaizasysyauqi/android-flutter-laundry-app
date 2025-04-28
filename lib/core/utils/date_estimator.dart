import 'package:tflite_flutter/tflite_flutter.dart';

class DateEstimator {
  static const String modelPath = 'laundry_completion_model.tflite';

  // // Add this method to fix the error
  // static DateTime calculateEstimatedCompletion(
  //     String laundrySpeed, double weight) {
  //   final now = DateTime.now();

  //   // Tentukan hari tambahan berdasarkan berat dan kecepatan laundry
  //   int additionalDays = 1; // Minimal 1 hari kerja

  //   switch (laundrySpeed.toLowerCase()) {
  //     case 'express':
  //       // 1 hari + tambahan 1 hari untuk setiap kelipatan 20 kg
  //       additionalDays += (weight / 20).ceil() - 1;
  //       break;
  //     case 'reguler':
  //     default:
  //       // 1 hari + tambahan 1 hari untuk setiap kelipatan 10 kg
  //       additionalDays += (weight / 10).ceil() - 1;
  //       break;
  //   }

  //   // Hitung estimasi dengan menambahkan hanya hari kerja (exclusing weekend)
  //   DateTime estimatedDate = now;
  //   int daysAdded = 0;

  //   while (daysAdded < additionalDays) {
  //     estimatedDate = estimatedDate.add(const Duration(days: 1));
  //     // Periksa apakah hari adalah hari kerja (Senin-Jumat, weekday 1-5)
  //     if (estimatedDate.weekday <= 5) {
  //       // 1 = Senin, 5 = Jumat
  //       daysAdded++;
  //     }
  //   }

  //   return estimatedDate;
  // }

  static Future<DateTime> calculateEstimatedCompletionWithAI(
    String laundrySpeed,
    double weight,
    int clothes,
    int queue,
    int weekday,
  ) async {
    final interpreter = await Interpreter.fromAsset(modelPath);
    final input = [
      [
        weight,
        laundrySpeed == 'Express' ? 1.0 : 0.0,
        queue.toDouble(),
        weekday.toDouble(),
        clothes.toDouble()
      ]
    ];
    final output = List.filled(1, List.filled(1, 0.0)).reshape([1, 1]);

    interpreter.run(input, output);
    final predictedHours = output[0][0]; // Output dalam hari, konversi ke jam

    // Hitung estimasi dengan menambahkan hanya hari kerja berdasarkan jam
    DateTime estimatedDate = DateTime.now();
    int totalHours = predictedHours.round();
    int hoursAdded = 0;

    while (hoursAdded < totalHours) {
      estimatedDate = estimatedDate.add(const Duration(hours: 1));
      if (estimatedDate.weekday <= 5) {
        // Hanya hitung jam pada hari kerja
        hoursAdded++;
      }
    }

    return estimatedDate;
  }

  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:00';
  }
}
