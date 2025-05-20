// File: lib/presentation/widgets/common/loading_indicator.dart
// Berisi widget untuk menampilkan indikator loading.
// Digunakan saat data sedang dimuat di berbagai layar.

// Mengimpor package dan file yang diperlukan.
import 'package:flutter/material.dart';
import 'package:flutter_laundry_app/presentation/style/colors/button_colors.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/indicator_sizes.dart';

// Widget untuk indikator loading
class LoadingIndicator extends StatelessWidget {
  // Ukuran indikator
  final double size;
  // Warna indikator
  final Color? color;

  // Konstruktor dengan parameter opsional
  const LoadingIndicator({
    super.key,
    this.size = IndicatorSizes.defaultLoadingSize, // Ukuran default
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          color: color ?? ButtonColors.loadingIndicatorSecondary, // Warna default
        ),
      ),
    );
  }
}