import 'package:flutter/material.dart';

import 'component/card_type.dart';
import 'component/icon_widget.dart';
import 'component/slidercard_widget.dart';
import 'constants.dart';

// Reusable widget for the entire BMI layout
class BMILayoutContainer extends StatelessWidget {
  final Color color; // Container color
  final CardType? selectedGender; // Selected gender (male/female)
  final Map<CardType, VoidCallback?> tapCallbacks; // Map of card types to tap callbacks
  final double weight; // Current weight value
  final double height; // Current height value
  final double? bmi; // Calculated BMI value
  final String? category; // Calculated BMI category
  final TextEditingController weightController; // Controller for weight TextField
  final TextEditingController heightController; // Controller for height TextField
  final ValueChanged<double> onWeightChanged; // Callback for weight changes
  final ValueChanged<double> onHeightChanged; // Callback for height changes

  BMILayoutContainer({
    required this.color,
    required this.selectedGender,
    required this.tapCallbacks,
    required this.weight,
    required this.height,
    required this.bmi,
    required this.category,
    required this.weightController,
    required this.heightController,
    required this.onWeightChanged,
    required this.onHeightChanged,
  });

  // Row configuration: card types
  final List<Map<String, dynamic>> rowConfigs = [
    {
      'types': [CardType.male, CardType.female],
    }, // Gender selection
    {
      'types': [CardType.weight, CardType.height]
    }, // Weight and height
    {
      'types': [CardType.calculate]
    }, // Calculate button
    {
      'types': [CardType.bmiValue, CardType.category]
    }, // BMI and category
    {
      'types': [CardType.changeColor],
    }, // Color change
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: rowConfigs.asMap().entries.map((entry) {
        final index = entry.key;
        final config = entry.value;
        final types = config['types'] as List<CardType>;

        return Expanded(
          child: types.length == 1
              ? CardWidget(
            type: types[0],
            color: color,
            onTap: tapCallbacks[types[0]],
          )
              : Row(
            children: [
              Expanded(
                child: index == 1
                    ? SliderCardWidget(
                  type: types[0],
                  color: color,
                  min: AppConstants.weightMin,
                  max: AppConstants.weightMax,
                  value: weight,
                  controller: weightController,
                  onChanged: onWeightChanged,
                )
                    : index == 3
                    ? TextCardWidget(
                  type: types[0],
                  color: color,
                  text: bmi != null ? bmi!.toStringAsFixed(1) : 'N/A',
                )
                    : CardWidget(
                  type: types[0],
                  color: color,
                  isSelected: index == 0 ? selectedGender == types[0] : false,
                  onTap: tapCallbacks[types[0]],
                ),
              ),
              if (types.length > 1)
                Expanded(
                  child: index == 1
                      ? SliderCardWidget(
                    type: types[1],
                    color: color,
                    min: AppConstants.heightMin,
                    max: AppConstants.heightMax,
                    value: height,
                    controller: heightController,
                    onChanged: onHeightChanged,
                  )
                      : index == 3
                      ? TextCardWidget(
                    type: types[1],
                    color: color,
                    text: category ?? 'N/A',
                  )
                      : CardWidget(
                    type: types[1],
                    color: color,
                    isSelected: index == 0 ? selectedGender == types[1] : false,
                    onTap: tapCallbacks[types[1]],
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

TextCardWidget({required type, required Color color, required String text}) {
}

class InputPage extends StatefulWidget {
  @override
  _InputPageState createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  // List of colors to cycle through
  List<Color> colors = AppConstants.colorList;
  int colorIndex = 0; // Current color index
  CardType? selectedGender; // Track selected gender (male/female)
  double weight = 70; // Initial weight (kg)
  double height = 170; // Initial height (cm)
  double? bmi; // Calculated BMI
  String? category; // Calculated BMI category
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();

  @override
  void dispose() {
    weightController.dispose();
    heightController.dispose();
    super.dispose();
  }

  // Function to change color
  void changeColor() {
    setState(() {
      colorIndex = (colorIndex + 1) % colors.length; // Cycle through colors
    });
  }

  // Function to select male
  void selectMale() {
    setState(() {
      selectedGender = CardType.male;
    });
  }

  // Function to select female
  void selectFemale() {
    setState(() {
      selectedGender = CardType.female;
    });
  }

  // Function to calculate BMI and category
  void calculateBMI() {
    if (selectedGender == null) return; // Require gender selection
    setState(() {
      // Calculate BMI: weight (kg) / (height (m))^2
      final heightInMeters = height / 100;
      bmi = weight / (heightInMeters * heightInMeters);

      // Determine category based on gender
      if (selectedGender == CardType.male) {
        if (bmi! < 18.5) {
          category = 'Underweight';
        } else if (bmi! < 25) {
          category = 'Normal';
        } else if (bmi! < 30) {
          category = 'Overweight';
        } else {
          category = 'Obese';
        }
      } else {
        if (bmi! < 18.0) {
          category = 'Underweight';
        } else if (bmi! < 24) {
          category = 'Normal';
        } else if (bmi! < 30) {
          category = 'Overweight';
        } else {
          category = 'Obese';
        }
      }
    });
  }

  // Map of card types to tap callbacks
  Map<CardType, VoidCallback?> get tapCallbacks => {
    CardType.male: selectMale,
    CardType.female: selectFemale,
    CardType.weight: null,
    CardType.height: null,
    CardType.calculate: calculateBMI,
    CardType.bmiValue: null,
    CardType.category: null,
    CardType.changeColor: changeColor,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BMI Calculator'),
      ),
      body: BMILayoutContainer(
        color: colors[colorIndex],
        selectedGender: selectedGender,
        tapCallbacks: tapCallbacks,
        weight: weight,
        height: height,
        bmi: bmi,
        category: category,
        weightController: weightController,
        heightController: heightController,
        onWeightChanged: (value) {
          setState(() {
            weight = value;
            weightController.text = value.toInt().toString();
          });
        },
        onHeightChanged: (value) {
          setState(() {
            height = value;
            heightController.text = value.toInt().toString();
          });
        },
      ),
    );
  }
}