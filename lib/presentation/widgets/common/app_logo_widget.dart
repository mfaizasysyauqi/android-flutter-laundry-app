import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_laundry_app/presentation/widgets/common/custom_circle_avatar.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/logo_sizes.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/margin_sizes.dart';

class AppLogoWidget extends StatelessWidget {
  final double size;
  final String appName;
  final TextStyle? textStyle;

  const AppLogoWidget({
    super.key,
    this.size = LogoSizes.avatarSize, // Use default from LogoSizes
    this.appName = 'LaundryGo',
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomCircleAvatar(
          svgPath: 'assets/svg/logo.svg',
        ),
        const SizedBox(
            height: MarginSizes.logoSpacing), // Updated from moderate
        SvgPicture.asset(
          'assets/svg/LaundryGo.svg',
          width: LogoSizes.appNameWidth, // Use defined size
        ),
      ],
    );
  }
}
