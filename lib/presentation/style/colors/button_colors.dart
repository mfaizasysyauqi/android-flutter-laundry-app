import 'package:flutter/material.dart';

class ButtonColors {
  static const Color loadingIndicatorDefault = Color(0xFF86A8CC);
  static const Color filterChipSelected =
      Color(0xFF95BBE3); // For selected filter chips
  static const Color loadingIndicatorSecondary =
      Color(0xFF95BBE3); // For LoadingIndicator default
  static const Color filterChipUnselected =
      Color(0xFFFFFFFF); // For unselected filter chips
  static const Color buttonTextColor =
      Color(0xFFFFFFFF); // For button text/icons in OrderCard
  static const Color startProcessing =
      Colors.green; // Renamed from green for "Start Processing"
  static const Color orderComplete = Colors.amber; // Already renamed
  static const Color cancelledOrder =
      Colors.red; // Renamed from red for cancelled state
  static const Color delete = Colors.redAccent;
  static const Color sendToHistory = Color(0xFF95BBE3);
}
