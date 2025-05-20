// File: lib/presentation/widgets/common/app_logo_widget.dart
// Berisi widget untuk menampilkan logo aplikasi dengan nama aplikasi di bawahnya.
// Digunakan pada layar splash atau halaman lain yang memerlukan logo.

// Mengimpor package dan file yang diperlukan.
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_laundry_app/presentation/widgets/common/custom_circle_avatar.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/logo_sizes.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/margin_sizes.dart';

// Widget untuk menampilkan logo aplikasi
class AppLogoWidget extends StatelessWidget {
  // Ukuran logo
  final double size;
  // Nama aplikasi
  final String appName;
  // Gaya teks opsional untuk nama aplikasi
  final TextStyle? textStyle;

  // Konstruktor dengan parameter opsional
  const AppLogoWidget({
    super.key,
    this.size = LogoSizes.avatarSize, // Gunakan ukuran default dari LogoSizes
    this.appName = 'LaundryGo', // Nama default aplikasi
    this.textStyle, // Gaya teks opsional
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Gunakan ukuran minimum untuk kolom
      children: [
        // Menampilkan logo dalam lingkaran
        CustomCircleAvatar(
          svgPath: 'assets/svg/logo.svg', // Path ke file SVG logo
        ),
        const SizedBox(
            height: MarginSizes.logoSpacing), // Jarak antara logo dan nama
        // Menampilkan nama aplikasi sebagai SVG
        SvgPicture.asset(
          'assets/svg/LaundryGo.svg',
          width: LogoSizes.appNameWidth, // Lebar nama aplikasi
        ),
      ],
    );
  }
}