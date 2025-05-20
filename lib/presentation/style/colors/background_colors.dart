// File: lib/presentation/style/colors/background_colors.dart
// Berisi definisi warna latar belakang untuk berbagai elemen UI dalam aplikasi.
// Digunakan untuk memastikan konsistensi warna di seluruh tampilan.

// Mengimpor package dan file yang diperlukan.
import 'package:flutter/material.dart';

// Kelas untuk mendefinisikan warna latar belakang
class BackgroundColors {
  // Warna umum untuk elemen UI
  // Warna untuk latar belakang kolom formulir
  static const Color formFieldFill = Color(0xFFFFFFFF);
  // Warna untuk latar belakang kartu
  static const Color card = Color(0xFFFFFFFF);
  // Warna transparan untuk elemen tanpa latar belakang
  static const Color transparent = Colors.transparent;
  // Warna hijau untuk indikasi keberhasilan
  static const Color success = Colors.green;
  // Warna merah untuk indikasi kesalahan
  static const Color error = Colors.red;
  // Warna abu-abu terang untuk latar belakang umum
  static const Color lightGrey = Color(0xFFF5F6FA);

  // Warna spesifik untuk fitur tertentu
  // Warna latar belakang dashboard pengguna
  static const Color dashboardBackground = Color(0xFF95BBE3);
  // Warna latar belakang AppBar
  static const Color appBarBackground = Color(0xFF95BBE3);
  // Warna latar belakang kontainer konten
  static const Color contentContainer = Color(0xFFFFFFFF);
  // Warna latar belakang avatar
  static const Color avatarBackground = Color(0xFFFFFFFF);
  // Warna latar belakang layar splash
  static const Color splashBackground = Color(0xFFFFFFFF);
}