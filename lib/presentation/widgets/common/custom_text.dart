import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_laundry_app/presentation/style/app_typography.dart';

class CustomText extends StatelessWidget {
  final String normalText;
  final String highlightedText;
  final VoidCallback? onTap;

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
            style: AppTypography.customTextNormal, // Use defined style
          ),
          TextSpan(
            text: highlightedText,
            style: AppTypography.customTextHighlighted, // Use defined style
            recognizer: TapGestureRecognizer()..onTap = onTap,
          ),
        ],
      ),
    );
  }
}