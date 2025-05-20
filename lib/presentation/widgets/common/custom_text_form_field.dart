// File: lib/presentation/widgets/common/custom_text_form_field.dart
// Berisi widget kolom formulir kustom dengan gaya konsisten dan dukungan interaksi.
// Digunakan untuk input teks di berbagai formulir aplikasi.

// Mengimpor package dan file yang diperlukan.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_laundry_app/presentation/style/app_typography.dart';
import 'package:flutter_laundry_app/presentation/style/colors/background_colors.dart';
import 'package:flutter_laundry_app/presentation/style/colors/border_colors.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/button_sizes.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/padding_sizes.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/border_sizes.dart';

// Widget kolom formulir kustom
class CustomTextFormField extends StatefulWidget {
  // Teks petunjuk
  final String hintText;
  // Teks label
  final String? labelText;
  // Kontroler teks
  final TextEditingController? controller;
  // Status teks tersembunyi
  final bool obscureText;
  // Tipe keyboard
  final TextInputType keyboardType;
  // Ikon sebelum teks
  final IconData? prefixIcon;
  // Ikon setelah teks
  final Widget? suffixIcon;
  // Aksi input teks
  final TextInputAction? textInputAction;
  // Fungsi validasi
  final String? Function(String?)? validator;
  // Status hanya baca
  final bool readOnly;
  // Status aktif
  final bool enabled;
  // Fungsi saat diketuk
  final VoidCallback? onTap;
  // Fungsi saat disimpan
  final void Function(String?)? onSaved;
  // Fungsi saat teks berubah
  final void Function(String)? onChanged;
  // Format input
  final List<TextInputFormatter>? inputFormatters;
  // Node fokus
  final FocusNode? focusNode;

  // Konstruktor dengan parameter wajib dan opsional
  const CustomTextFormField({
    super.key,
    required this.hintText,
    this.labelText,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.textInputAction,
    this.validator,
    this.readOnly = false,
    this.enabled = true,
    this.onTap,
    this.onSaved,
    this.onChanged,
    this.inputFormatters,
    this.focusNode,
  });

  @override
  CustomTextFormFieldState createState() => CustomTextFormFieldState();
}

// State untuk mengelola interaksi kolom formulir
class CustomTextFormFieldState extends State<CustomTextFormField> {
  // Status hover mouse
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: widget.enabled ? (_) => setState(() => isHovered = true) : null,
      onExit: widget.enabled ? (_) => setState(() => isHovered = false) : null,
      child: TextFormField(
        controller: widget.controller,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        validator: widget.validator,
        readOnly: widget.readOnly || !widget.enabled,
        onTap: widget.enabled ? widget.onTap : null,
        onChanged: widget.enabled ? widget.onChanged : null,
        inputFormatters: widget.inputFormatters,
        focusNode: widget.focusNode,
        decoration: InputDecoration(
          hintText: widget.hintText,
          labelText: widget.labelText,
          labelStyle: AppTypography.label,
          prefixIcon:
              widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
          suffixIcon: widget.suffixIcon,
          filled: true,
          fillColor: widget.enabled
              ? BackgroundColors.formFieldFill
              : BackgroundColors.formFieldFill.withAlpha(128), // Warna saat dinonaktifkan
          contentPadding: const EdgeInsets.symmetric(
            vertical: PaddingSizes.formFieldVertical,
            horizontal: PaddingSizes.formFieldHorizontal,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ButtonSizes.borderRadius),
            borderSide: const BorderSide(
              color: BorderColors.defaultBorder,
              width: BorderSizes.thin,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ButtonSizes.borderRadius),
            borderSide: BorderSide(
              color: isHovered && widget.enabled
                  ? BorderColors.focusedBorder
                  : BorderColors.defaultBorder,
              width: BorderSizes.thin,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ButtonSizes.borderRadius),
            borderSide: const BorderSide(
              color: BorderColors.focusedBorder,
              width: BorderSizes.medium,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ButtonSizes.borderRadius),
            borderSide: const BorderSide(
              color: BorderColors.disabledBorder,
              width: BorderSizes.thin,
            ),
          ),
        ),
      ),
    );
  }
}