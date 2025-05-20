// File: lib/presentation/widgets/common/custom_text.dart
// Berisi widget untuk menampilkan teks dengan bagian yang disorot dan interaktif.
// Digunakan untuk teks dengan tautan atau aksi tertentu.

// Mengimpor package dan file yang diperlukan.
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_laundry_app/presentation/style/app_typography.dart';

// Widget untuk teks kustom dengan bagian yang disorot
class CustomText extends StatelessWidget {
  // Teks normal
  final String normalText;
  // Teks yang disorot
  final String highlightedText;
  // Fungsi saat teks disorot diketuk
  final VoidCallback? onTap;

  // Konstruktor dengan parameter wajib dan opsional
  const CustomText({
    super.key,
    required this.normalText,
    required this.highlightedText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: normalText,
            style: AppTypography.customTextNormal, // Gaya teks normal
          ),
          TextSpan(
            text: highlightedText,
            style: AppTypography.customTextHighlighted, // Gaya teks disorot
            recognizer: TapGestureRecognizer()..onTap = onTap, // Aksi ketuk
          ),
        ],
      ),
    );
  }
}