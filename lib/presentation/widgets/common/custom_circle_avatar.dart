import 'package:flutter/material.dart';
import 'package:flutter_laundry_app/presentation/style/colors/background_colors.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/logo_sizes.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomCircleAvatar extends StatelessWidget {
  final String svgPath;
  final double radius;
  final Color backgroundColor;

  const CustomCircleAvatar({
    super.key,
    required this.svgPath,
    this.radius = LogoSizes.circleAvatarRadius, // Use default from LogoSizes
    this.backgroundColor = BackgroundColors.avatarBackground, // Updated to use specific name
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
      ),
      child: ClipOval(
        child: SvgPicture.asset(
          svgPath,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}