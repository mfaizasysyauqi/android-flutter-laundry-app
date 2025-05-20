// File: lib/presentation/style/colors/border_colors.dart
// Berisi definisi warna untuk garis tepi (border) elemen UI.
// Digunakan untuk memastikan konsistensi warna garis tepi di seluruh aplikasi.

// Mengimpor package dan file yang diperlukan.
import 'package:flutter/material.dart';

// Kelas untuk mendefinisikan warna garis tepi
class BorderColors {
  // Warna untuk garis pembatas
  static const Color divider = Color(0xFFEEEEEE);
  // Warna default untuk garis tepi
  static const Color defaultBorder = Colors.grey;
  // Warna untuk garis tepi saat elemen dalam fokus
  static const Color focusedBorder = Colors.lightBlueAccent;
  // Warna untuk garis tepi saat elemen dinonaktifkan
  static const Color disabledBorder = Colors.grey;
}