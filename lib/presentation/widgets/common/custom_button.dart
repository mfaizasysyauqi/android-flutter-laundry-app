// File: lib/presentation/widgets/common/custom_button.dart
// Berisi widget tombol kustom dengan dukungan loading state dan gaya yang konsisten.
// Digunakan untuk tombol interaktif di seluruh aplikasi.

// Mengimpor package dan file yang diperlukan.
import 'package:flutter/material.dart';
import 'package:flutter_laundry_app/presentation/style/app_typography.dart';
import 'package:flutter_laundry_app/presentation/style/colors/button_colors.dart';
import 'package:flutter_laundry_app/presentation/style/colors/text_colors.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/button_sizes.dart';

// Widget untuk tombol kustom
class CustomButton extends StatelessWidget {
  // Teks pada tombol
  final String text;
  // Fungsi yang dipanggil saat tombol ditekan
  final VoidCallback? onPressed;
  // Warna latar belakang tombol
  final Color? color;
  // Warna teks tombol
  final Color? textColor;
  // Tinggi tombol
  final double height;
  // Lebar tombol
  final double width;
  // Radius sudut tombol
  final double borderRadius;
  // Status loading tombol
  final bool isLoading;

  // Konstruktor dengan parameter wajib dan opsional
  const CustomButton({
    super.key,
    required this.text,
    this.onPressed, // Nullable untuk mendukung status dinonaktifkan
    this.color,
    this.textColor,
    this.height = ButtonSizes.defaultHeight, // Tinggi default
    this.width = double.infinity, // Lebar penuh
    this.borderRadius = ButtonSizes.borderRadius, // Radius sudut default
    this.isLoading = false, // Status loading default
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height, // Atur tinggi tombol
      width: width, // Atur lebar tombol
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed, // Nonaktifkan saat loading
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? ButtonColors.loadingIndicatorDefault, // Warna latar
          foregroundColor: textColor ?? TextColors.lightText, // Warna teks
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius), // Bentuk sudut
          ),
          minimumSize: Size(width, height), // Ukuran minimum tombol
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2, // Ketebalan indikator
                  valueColor: AlwaysStoppedAnimation<Color>(TextColors.lightText),
                ),
              )
            : Text(
                text,
                style: AppTypography.customButtonText, // Gaya teks tombol
              ),
      ),
    );
  }
}