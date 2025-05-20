// File: core/network/network_info.dart
// Berisi abstraksi dan implementasi untuk memeriksa status koneksi jaringan.

// Mengimpor package internet_connection_checker untuk memeriksa koneksi internet.
import 'package:internet_connection_checker/internet_connection_checker.dart';

// Abstrak kelas NetworkInfo mendefinisikan kontrak untuk memeriksa koneksi jaringan.
abstract class NetworkInfo {
  // Getter untuk mendapatkan status koneksi (true jika terhubung, false jika tidak).
  Future<bool> get isConnected;
}

// Implementasi dari NetworkInfo menggunakan InternetConnectionChecker.
class NetworkInfoImpl implements NetworkInfo {
  // Properti untuk menyimpan instance InternetConnectionChecker.
  final InternetConnectionChecker connectionChecker;

  // Konstruktor yang menerima instance InternetConnectionChecker.
  NetworkInfoImpl(this.connectionChecker);

  // Override getter isConnected untuk memeriksa apakah ada koneksi internet.
  // Mengembalikan Future<bool> berdasarkan hasil pengecekan dari connectionChecker.
  @override
  Future<bool> get isConnected => connectionChecker.hasConnection;
}