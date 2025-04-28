import 'package:flutter/material.dart';
import 'package:flutter_laundry_app/presentation/style/app_typography.dart';
import 'package:flutter_laundry_app/presentation/style/colors/button_colors.dart';
import 'package:flutter_laundry_app/presentation/style/colors/text_colors.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/button_sizes.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed; // Changed to nullable to handle disabled state
  final Color? color;
  final Color? textColor;
  final double height;
  final double width;
  final double borderRadius;
  final bool isLoading; // Added isLoading parameter

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.color,
    this.textColor,
    this.height = ButtonSizes.defaultHeight,
    this.width = double.infinity,
    this.borderRadius = ButtonSizes.borderRadius,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed, // Disable button when loading
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? ButtonColors.loadingIndicatorDefault,
          foregroundColor: textColor ?? TextColors.lightText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          minimumSize: Size(width, height),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(TextColors.lightText),
                ),
              )
            : Text(
                text,
                style: AppTypography.customButtonText,
              ),
      ),
    );
  }
}