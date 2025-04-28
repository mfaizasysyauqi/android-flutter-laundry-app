import 'package:flutter/material.dart';

class TextColors {
  static const Color titleText = Color(0xFF1F2227);      // For headings/titles
  static const Color dataText = Color(0xFF1F2227);       // For data fields
  static const Color supportText = Color(0xFF606060);    // For form instructions and labels
  static const Color emptyStateText = Color(0xFF898B96); // For empty state subtitles
  static const Color lightText = Color(0xFFFFFFFF);      // For white text in welcome, app bars, buttons
  static const Color metadataText = Color(0xFF757575);   // For date and speed metadata
  static const Color formHintText = Color(0xFF9E9E9E);   // For form subtitles/hints
  static const Color bodyText = Color(0xFF1F2227);       // For standard body text
  static const Color highlightedText = Color(0xFF95BBE3); // For highlighted text
  static const Color pureBlackText = Color(0xFF000000);  // For pure black text
  
  // Replacing 'red' with more specific names
  static const Color errorTextColor = Colors.red;        // For error messages
  static const Color cancelActionTextColor = Color(0xFFD32F2F); // For cancel actions (a specific red shade: Red 700)
}