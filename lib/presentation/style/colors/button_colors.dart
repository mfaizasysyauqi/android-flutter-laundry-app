// File: lib/presentation/style/colors/button_colors.dart
// Berisi definisi warna untuk tombol dan elemen interaktif lainnya.
// Digunakan untuk memastikan konsistensi warna tombol di seluruh aplikasi.

// Mengimpor package dan file yang diperlukan.
import 'package:flutter/material.dart';

// Kelas untuk mendefinisikan warna tombol
class ButtonColors {
  // Warna untuk indikator loading default
  static const Color loadingIndicatorDefault = Color(0xFF86A8CC);
  // Warna untuk filter chip saat dipilih
  static const Color filterChipSelected = Color(0xFF95BBE3);
  // Warna untuk indikator loading sekunder
  static const Color loadingIndicatorSecondary = Color(0xFF95BBE3);
  // Warna untuk filter chip saat tidak dipilih
  static const Color filterChipUnselected = Color(0xFFFFFFFF);
  // Warna untuk teks atau ikon pada tombol
  static const Color buttonTextColor = Color(0xFFFFFFFF);
  // Warna untuk tombol "Mulai Proses"
  static const Color startProcessing = Colors.green;
  // Warna untuk tombol "Pesanan Selesai"
  static const Color orderComplete = Colors.amber;
  // Warna untuk tombol "Pesanan Dibatalkan"
  static const Color cancelledOrder = Colors.red;
  // Warna untuk tombol hapus
  static const Color delete = Colors.redAccent;
  // Warna untuk tombol "Kirim ke Riwayat"
  static const Color sendToHistory = Color(0xFF95BBE3);
}