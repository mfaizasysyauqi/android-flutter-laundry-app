// File: lib/presentation/widgets/common/custom_circle_avatar.dart
// Berisi widget untuk menampilkan avatar lingkaran dengan gambar SVG.
// Digunakan untuk logo atau ikon berbentuk lingkaran.

// Mengimpor package dan file yang diperlukan.
import 'package:flutter/material.dart';
import 'package:flutter_laundry_app/presentation/style/colors/background_colors.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/logo_sizes.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Widget untuk avatar lingkaran kustom
class CustomCircleAvatar extends StatelessWidget {
  // Path ke file SVG
  final String svgPath;
  // Radius avatar
  final double radius;
  // Warna latar belakang avatar
  final Color backgroundColor;

  // Konstruktor dengan parameter wajib dan opsional
  const CustomCircleAvatar({
    super.key,
    required this.svgPath,
    this.radius = LogoSizes.circleAvatarRadius, // Radius default
    this.backgroundColor = BackgroundColors.avatarBackground, // Warna default
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2, // Lebar sesuai diameter
      height: radius * 2, // Tinggi sesuai diameter
      decoration: BoxDecoration(
        shape: BoxShape.circle, // Bentuk lingkaran
        color: backgroundColor, // Warna latar belakang
      ),
      child: ClipOval(
        child: SvgPicture.asset(
          svgPath,
          width: radius * 2, // Lebar SVG
          height: radius * 2, // Tinggi SVG
          fit: BoxFit.cover, // Skala gambar
        ),
      ),
    );
  }
}