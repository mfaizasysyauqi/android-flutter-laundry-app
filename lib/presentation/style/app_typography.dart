// File: lib/presentation/style/app_typography.dart
// Berisi definisi gaya tipografi untuk teks dalam aplikasi.
// Menggabungkan ukuran, warna, dan ketebalan teks untuk memastikan konsistensi gaya teks di seluruh tampilan.

// Mengimpor package dan file yang diperlukan.
import 'package:flutter/material.dart';
import 'package:flutter_laundry_app/presentation/style/colors/text_colors.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/text_sizes.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/text_decor_sizes.dart';

// Kelas untuk mendefinisikan gaya tipografi
class AppTypography {
  // Ketebalan font
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight semiBold = FontWeight.w600;

  // Gaya untuk nama lengkap pada sambutan
  static TextStyle welcomeFullName = TextStyle(
    fontSize: TextSizes.welcomeNameText,
    fontWeight: bold,
    color: TextColors.lightText,
  );
  // Gaya untuk teks intro pada sambutan
  static TextStyle welcomeIntro = TextStyle(
    fontSize: TextSizes.welcomeIntroText,
    fontWeight: regular,
    color: TextColors.lightText,
  );
  // Gaya untuk judul bagian
  static TextStyle sectionTitle = TextStyle(
    fontSize: TextSizes.sectionHeaderText,
    fontWeight: bold,
    color: TextColors.titleText,
  );
  // Gaya untuk judul AppBar
  static TextStyle appBarTitle = TextStyle(
    fontSize: TextSizes.appBarTitleText,
    fontWeight: bold,
    color: TextColors.lightText,
  );
  // Gaya untuk judul AppBar dengan warna gelap
  static TextStyle darkAppBarTitle = TextStyle(
    fontSize: TextSizes.appBarTitleText,
    fontWeight: bold,
    color: TextColors.titleText,
  );
  // Gaya untuk petunjuk formulir
  static TextStyle formInstruction = TextStyle(
    fontSize: TextSizes.generalText,
    fontWeight: regular,
    color: TextColors.supportText,
  );
  // Gaya untuk label
  static TextStyle label = TextStyle(
    fontSize: TextSizes.subtitleText,
    fontWeight: regular,
    color: TextColors.supportText,
  );
  // Gaya untuk teks tanggal
  static TextStyle date = TextStyle(
    fontSize: TextSizes.dateSmall,
    fontWeight: regular,
    color: TextColors.metadataText,
  );
  // Gaya untuk teks harga
  static TextStyle price = TextStyle(
    fontSize: TextSizes.priceText,
    fontWeight: bold,
    color: TextColors.dataText,
  );
  // Gaya untuk ID pesanan
  static TextStyle orderId = TextStyle(
    fontSize: TextSizes.orderIdentifier,
    fontWeight: bold,
    color: TextColors.dataText,
  );
  // Gaya untuk nama laundry
  static TextStyle laundryName = TextStyle(
    fontSize: TextSizes.nameText,
    fontWeight: semiBold,
    color: TextColors.dataText,
  );
  // Gaya untuk kecepatan laundry
  static TextStyle laundrySpeed = TextStyle(
    fontSize: TextSizes.speedText,
    fontWeight: regular,
    color: TextColors.metadataText,
  );
  // Gaya untuk berat pakaian
  static TextStyle weightClothes = TextStyle(
    fontSize: TextSizes.detailText,
    fontWeight: regular,
    color: TextColors.dataText,
  );
  // Gaya untuk teks tombol
  static TextStyle buttonText = TextStyle(
    fontSize: TextSizes.buttonLabel,
    fontWeight: bold,
    color: TextColors.lightText,
  );
  // Gaya untuk teks tombol kustom
  static TextStyle customButtonText = TextStyle(
    fontSize: TextSizes.generalText,
    fontWeight: bold,
    color: TextColors.lightText,
  );
  // Gaya untuk teks pembatalan
  static TextStyle cancelText = TextStyle(
    fontSize: TextSizes.buttonLabel,
    fontWeight: regular,
    color: TextColors.cancelActionTextColor,
    decoration: TextDecoration.underline,
    decorationColor: TextColors.cancelActionTextColor,
    decorationThickness: TextDecorSizes.cancelUnderlineThickness,
    height: TextDecorSizes.cancelTextLineHeight,
  );
  // Gaya untuk teks kesalahan
  static TextStyle errorText = TextStyle(
    fontSize: TextSizes.generalText,
    fontWeight: regular,
    color: TextColors.lightText,
  );
  // Gaya untuk judul keadaan kosong
  static TextStyle emptyStateTitle = TextStyle(
    fontSize: TextSizes.modalTitle,
    fontWeight: bold,
    color: TextColors.titleText,
  );
  // Gaya untuk subjudul keadaan kosong
  static TextStyle emptyStateSubtitle = TextStyle(
    fontSize: TextSizes.generalText,
    fontWeight: regular,
    color: TextColors.emptyStateText,
  );
  // Gaya untuk judul modal
  static TextStyle modalTitle = TextStyle(
    fontSize: TextSizes.modalTitle,
    fontWeight: bold,
    color: TextColors.titleText,
  );
  // Gaya untuk judul formulir
  static TextStyle formTitle = TextStyle(
    fontSize: TextSizes.modalTitle,
    fontWeight: bold,
    color: TextColors.titleText,
  );
  // Gaya untuk subjudul formulir
  static TextStyle formSubtitle = TextStyle(
    fontSize: TextSizes.dateSmall,
    fontWeight: regular,
    color: TextColors.formHintText,
  );
  // Gaya untuk teks normal kustom
  static TextStyle customTextNormal = TextStyle(
    fontSize: TextSizes.generalText,
    color: TextColors.bodyText,
  );
  // Gaya untuk teks disorot kustom
  static TextStyle customTextHighlighted = TextStyle(
    fontSize: TextSizes.generalText,
    fontWeight: bold,
    color: TextColors.highlightedText,
  );
  // Gaya untuk teks tubuh standar
  static const TextStyle bodyText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );
}