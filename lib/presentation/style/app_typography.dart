import 'package:flutter/material.dart';
import 'package:flutter_laundry_app/presentation/style/colors/text_colors.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/text_sizes.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/text_decor_sizes.dart'; // New import

class AppTypography {
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight semiBold = FontWeight.w600;

  static TextStyle welcomeFullName = TextStyle(
    fontSize: TextSizes.welcomeNameText,
    fontWeight: bold,
    color: TextColors.lightText,
  );
  static TextStyle welcomeIntro = TextStyle(
    fontSize: TextSizes.welcomeIntroText,
    fontWeight: regular,
    color: TextColors.lightText,
  );
  static TextStyle sectionTitle = TextStyle(
    fontSize: TextSizes.sectionHeaderText,
    fontWeight: bold,
    color: TextColors.titleText,
  );
  static TextStyle appBarTitle = TextStyle(
    fontSize: TextSizes.appBarTitleText,
    fontWeight: bold,
    color: TextColors.lightText,
  );
  static TextStyle darkAppBarTitle = TextStyle(
    fontSize: TextSizes.appBarTitleText,
    fontWeight: bold,
    color: TextColors.titleText,
  );
  static TextStyle formInstruction = TextStyle(
    fontSize: TextSizes.generalText,
    fontWeight: regular,
    color: TextColors.supportText,
  );
  static TextStyle label = TextStyle(
    fontSize: TextSizes.subtitleText,
    fontWeight: regular,
    color: TextColors.supportText,
  );
  static TextStyle date = TextStyle(
    fontSize: TextSizes.dateSmall,
    fontWeight: regular,
    color: TextColors.metadataText,
  );
  static TextStyle price = TextStyle(
    fontSize: TextSizes.priceText,
    fontWeight: bold,
    color: TextColors.dataText,
  );
  static TextStyle orderId = TextStyle(
    fontSize: TextSizes.orderIdentifier,
    fontWeight: bold,
    color: TextColors.dataText,
  );
  static TextStyle laundryName = TextStyle(
    fontSize: TextSizes.nameText,
    fontWeight: semiBold,
    color: TextColors.dataText,
  );
  static TextStyle laundrySpeed = TextStyle(
    fontSize: TextSizes.speedText,
    fontWeight: regular,
    color: TextColors.metadataText,
  );
  static TextStyle weightClothes = TextStyle(
    fontSize: TextSizes.detailText,
    fontWeight: regular,
    color: TextColors.dataText,
  );
  static TextStyle buttonText = TextStyle(
    fontSize: TextSizes.buttonLabel,
    fontWeight: bold,
    color: TextColors.lightText,
  );
  static TextStyle customButtonText = TextStyle(
    fontSize: TextSizes.generalText,
    fontWeight: bold,
    color: TextColors.lightText,
  );
  static TextStyle cancelText = TextStyle(
    fontSize: TextSizes.buttonLabel,
    fontWeight: regular,
    color: TextColors.cancelActionTextColor,
    decoration: TextDecoration.underline,
    decorationColor: TextColors.cancelActionTextColor,
    decorationThickness:
        TextDecorSizes.cancelUnderlineThickness, // Updated from 1.5
    height: TextDecorSizes.cancelTextLineHeight, // Updated from 1.8
  );

  static TextStyle errorText = TextStyle(
    fontSize: TextSizes.generalText,
    fontWeight: regular,
    color: TextColors.lightText,
  );
  static TextStyle emptyStateTitle = TextStyle(
    fontSize: TextSizes.modalTitle,
    fontWeight: bold,
    color: TextColors.titleText,
  );
  static TextStyle emptyStateSubtitle = TextStyle(
    fontSize: TextSizes.generalText,
    fontWeight: regular,
    color: TextColors.emptyStateText,
  );
  static TextStyle modalTitle = TextStyle(
    fontSize: TextSizes.modalTitle,
    fontWeight: bold,
    color: TextColors.titleText,
  );
  static TextStyle formTitle = TextStyle(
    fontSize: TextSizes.modalTitle,
    fontWeight: bold,
    color: TextColors.titleText,
  );
  static TextStyle formSubtitle = TextStyle(
    fontSize: TextSizes.dateSmall,
    fontWeight: regular,
    color: TextColors.formHintText,
  );
  static TextStyle customTextNormal = TextStyle(
    fontSize: TextSizes.generalText,
    color: TextColors.bodyText,
  );
  static TextStyle customTextHighlighted = TextStyle(
    fontSize: TextSizes.generalText,
    fontWeight: bold,
    color: TextColors.highlightedText,
  );
  static const TextStyle bodyText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );
}
