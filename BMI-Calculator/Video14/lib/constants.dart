import 'package:flutter/material.dart';

// Constants for Container properties and styles in the BMI calculator app
class AppConstants {
  // Container properties
  static const EdgeInsets containerMargin = EdgeInsets.all(10);
  static const BorderRadius containerBorderRadius = BorderRadius.all(Radius.circular(10));
  static const Border selectedBorder = Border.fromBorderSide(
    BorderSide(color: Colors.white, width: 2),
  );

  // Icon properties
  static const double iconSize = 40;
  static const Color iconColor = Colors.white;

  // Text properties
  static const TextStyle textStyle = TextStyle(
    fontSize: 18,
    color: Colors.white,
  );
  static const TextStyle sliderTextStyle = TextStyle(
    fontSize: 16,
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle resultTextStyle = TextStyle(
    fontSize: 20,
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle inputTextStyle = TextStyle(
    fontSize: 16,
    color: Colors.white,
    fontWeight: FontWeight.normal,
  );
  static const TextStyle unitTextStyle = TextStyle(
    fontSize: 14,
    color: Colors.white,
    fontWeight: FontWeight.normal,
  );

  // Colors
  static const Color defaultCardColor = Color(0xFF1C1F32);
  static const List<Color> colorList = [
    defaultCardColor,
    Colors.teal,
    Colors.purple,
    Colors.blueGrey,
  ];

  // Spacing
  static const double iconTextSpacing = 10;

  // Slider ranges
  static const double weightMin = 30;
  static const double weightMax = 150;
  static const double heightMin = 100;
  static const double heightMax = 250;
}