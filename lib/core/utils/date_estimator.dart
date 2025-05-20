// File: date_estimator.dart
// Berisi kelas DateEstimator untuk menghitung estimasi waktu penyelesaian laundry menggunakan metode berbasis aturan dan AI.

// Mengimpor package tflite_flutter untuk menjalankan model TensorFlow Lite.
import 'package:tflite_flutter/tflite_flutter.dart';

// Kelas DateEstimator untuk menghitung estimasi waktu penyelesaian laundry.
class DateEstimator {
  // Path ke model TensorFlow Lite yang digunakan untuk prediksi berbasis AI.
  static const String modelPath = 'assets/laundry_completion_model/laundry_completion_model.tflite';
  
  // Daftar nilai minimum untuk normalisasi input model AI.
  static const List<double> scalerMin = [5.0, 0.0, 0.0, 0.0, 5.0, 0.0];
  
  // Daftar nilai maksimum untuk normalisasi input model AI.
  static const List<double> scalerMax = [100.0, 1.0, 15.0, 6.0, 100.0, 144.0];

  // Method untuk menormalkan input untuk model AI.
  // Normalisasi dilakukan dengan rumus: (x - min) / (max - min).
  static List<double> _normalizeInput(List<double> input) {
    // Validasi panjang input sesuai dengan scalerMin.
    if (input.length != scalerMin.length) {
      throw Exception('Input length (${input.length}) does not match expected length (${scalerMin.length})');
    }
    List<double> normalizedInput = [];
    for (int i = 0; i < input.length; i++) {
      // Normalisasi nilai input dan batasi antara 0.0 dan 1.0.
      double normalizedValue =
          (input[i] - scalerMin[i]) / (scalerMax[i] - scalerMin[i]);
      normalizedValue = normalizedValue.clamp(0.0, 1.0);
      normalizedInput.add(normalizedValue);
    }
    return normalizedInput;
  }

  // Method non-AI untuk menghitung estimasi waktu penyelesaian berdasarkan aturan sederhana.
  static DateTime calculateEstimatedCompletion(
      String laundrySpeed, double weight) {
    // Ambil waktu saat ini sebagai dasar perhitungan.
    final now = DateTime.now();
    int additionalDays = 1; // Minimum 1 hari kerja.

    // Tentukan jumlah hari tambahan berdasarkan kecepatan laundry dan berat.
    switch (laundrySpeed.toLowerCase()) {
      case 'express':
        additionalDays += (weight / 20).ceil() - 1;
        break;
      case 'reguler':
      default:
        additionalDays += (weight / 10).ceil() - 1;
        break;
    }

    // Tambahkan hari hanya untuk hari kerja (Senin-Jumat).
    DateTime estimatedDate = now;
    int daysAdded = 0;
    while (daysAdded < additionalDays) {
      estimatedDate = estimatedDate.add(const Duration(days: 1));
      if (estimatedDate.weekday <= 5) {
        daysAdded++; // Hanya hitung hari kerja.
      }
    }
    return estimatedDate;
  }

  // Method AI untuk menghitung estimasi waktu penyelesaian menggunakan model TensorFlow Lite.
  static Future<DateTime> calculateEstimatedCompletionWithAI(
    String laundrySpeed,
    double weight,
    double clothes,
    int queue,
    int weekday,
    double avgCompletionHours,
  ) async {
    // Validasi input hari (1-7).
    if (weekday < 1 || weekday > 7) {
      throw Exception('Invalid weekday: $weekday. Must be between 1 and 7.');
    }

    // Siapkan input untuk model AI dengan membatasi nilai dalam rentang yang valid.
    final input = [
      weight.clamp(5.0, 100.0),
      laundrySpeed.toLowerCase() == 'express' ? 1.0 : 0.0,
      queue.toDouble().clamp(0.0, 15.0),
      (weekday - 1).toDouble(), // Normalisasi weekday (1-7 menjadi 0-6).
      clothes.clamp(5.0, 100.0),
      avgCompletionHours.clamp(0.0, 144.0),
    ];

    // Normalisasi input menggunakan method _normalizeInput.
    final normalizedInput = _normalizeInput(input);

    // Muat model TensorFlow Lite dari aset.
    final interpreter = await Interpreter.fromAsset(modelPath);
    
    // Siapkan output untuk menyimpan hasil prediksi model.
    final output = List.filled(1, List.filled(1, 0.0)).reshape([1, 1]);

    // Jalankan model dengan input yang telah dinormalisasi.
    interpreter.run([normalizedInput], output);
    
    // Ambil hasil prediksi dalam jumlah hari.
    final predictedDays = output[0][0];

    // Tutup interpreter untuk mengosongkan sumber daya.
    interpreter.close();

    // Konversi hari prediksi menjadi jam.
    final predictedHours = (predictedDays * 24).toInt();
    if (predictedHours < 0) {
      throw Exception('Negative prediction from model: $predictedHours hours');
    }

    // Tambahkan jam hanya untuk hari kerja (Senin-Jumat).
    DateTime estimatedDate = DateTime.now();
    int hoursAdded = 0;
    while (hoursAdded < predictedHours) {
      estimatedDate = estimatedDate.add(const Duration(hours: 1));
      if (estimatedDate.weekday <= 5) {
        hoursAdded++; // Hanya hitung jam pada hari kerja.
      }
    }

    return estimatedDate;
  }

  // Method untuk memformat tanggal menjadi string dengan format 'dd/mm/yyyy hh:00'.
  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:00';
  }
}