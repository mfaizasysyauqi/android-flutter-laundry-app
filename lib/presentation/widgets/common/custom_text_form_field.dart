import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_laundry_app/presentation/style/app_typography.dart';
import 'package:flutter_laundry_app/presentation/style/colors/background_colors.dart';
import 'package:flutter_laundry_app/presentation/style/colors/border_colors.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/button_sizes.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/padding_sizes.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/border_sizes.dart';

class CustomTextFormField extends StatefulWidget {
  final String hintText;
  final String? labelText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final bool readOnly;
  final bool enabled;
  final VoidCallback? onTap;
  final void Function(String?)? onSaved;
  final void Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode; // Added focusNode parameter

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
    this.focusNode, // Include in constructor
  });

  @override
  CustomTextFormFieldState createState() => CustomTextFormFieldState();
}

class CustomTextFormFieldState extends State<CustomTextFormField> {
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
        focusNode: widget.focusNode, // Pass focusNode to TextFormField
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
              : BackgroundColors.formFieldFill.withAlpha(128),
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