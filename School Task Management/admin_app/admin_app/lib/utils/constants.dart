import 'package:flutter/material.dart';

class AppConstants {
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Colors.purple, Colors.red], // Changed to Purple to Red
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Colors.white, Colors.grey], // Unchanged
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color primaryColor = Colors.indigo; // Unchanged

  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static const TextStyle subheadingStyle = TextStyle(
    fontSize: 16,
    color: Colors.black54,
  );

  static const String logoPath = 'assets/images/logo.png';
  static const String adminWelcomePath = 'assets/images/admin_welcome.png';
}