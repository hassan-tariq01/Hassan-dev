import 'package:flutter/material.dart';

enum CardType {
  male,
  female,
  weight,
  height,
  calculate,
  bmiValue,
  category,
  changeColor,
}

extension CardTypeExtension on CardType {
  String get displayText {
    switch (this) {
      case CardType.male:
        return 'Male';
      case CardType.female:
        return 'Female';
      case CardType.weight:
        return 'Weight (kg)';
      case CardType.height:
        return 'Height (cm)';
      case CardType.calculate:
        return 'Calculate Button';
      case CardType.bmiValue:
        return 'BMI Value';
      case CardType.category:
        return 'Category';
      case CardType.changeColor:
        return 'Change Color';
    }
  }

  IconData get icon {
    switch (this) {
      case CardType.male:
        return Icons.male;
      case CardType.female:
        return Icons.female;
      case CardType.weight:
        return Icons.fitness_center;
      case CardType.height:
        return Icons.height;
      case CardType.calculate:
        return Icons.calculate;
      case CardType.bmiValue:
        return Icons.assessment;
      case CardType.category:
        return Icons.category;
      case CardType.changeColor:
        return Icons.color_lens;
    }
  }
}