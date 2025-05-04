import 'package:flutter/material.dart';
import 'component/icon_widget.dart';

// Reusable widget for the entire BMI layout
class BMILayoutContainer extends StatelessWidget {
  final Color color; // Container color
  final VoidCallback onColorChange; // Callback for color change
  final String? selectedGender; // Selected gender (male/female)
  final VoidCallback onMaleSelect; // Callback for male selection
  final VoidCallback onFemaleSelect; // Callback for female selection

  BMILayoutContainer({
    required this.color,
    required this.onColorChange,
    required this.selectedGender,
    required this.onMaleSelect,
    required this.onFemaleSelect,
  });

  // Row configuration: label(s), optional tap callback, and interactivity
  final List<Map<String, dynamic>> rowConfigs = [
    {'labels': ['Male', 'Female'], 'interactive': true}, // Gender selection
    {'labels': ['Weight (kg)', 'Height (cm)']}, // Weight and height
    {'labels': ['Calculate Button']}, // Calculate button
    {'labels': ['BMI Value', 'Category']}, // BMI and category
    {'labels': ['Change Color'], 'onTap': true}, // Color change
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: rowConfigs.asMap().entries.map((entry) {
        final index = entry.key;
        final config = entry.value;
        final labels = config['labels'] as List<String>;
        final onTap = config['onTap'] == true ? onColorChange : null;
        final isInteractive = config['interactive'] == true;

        return Expanded(
          child: labels.length == 1
              ? GestureDetector(
            onTap: onTap,
            child: CardWidget(
              label: labels[0],
              color: color,
            ),
          )
              : Row(
            children: [
              Expanded(
                child: isInteractive && index == 0
                    ? GestureDetector(
                  onTap: onMaleSelect,
                  child: CardWidget(
                    label: labels[0],
                    color: color,
                    isSelected: selectedGender == labels[0],
                  ),
                )
                    : CardWidget(
                  label: labels[0],
                  color: color,
                ),
              ),
              Expanded(
                child: isInteractive && index == 0
                    ? GestureDetector(
                  onTap: onFemaleSelect,
                  child: CardWidget(
                    label: labels[1],
                    color: color,
                    isSelected: selectedGender == labels[1],
                  ),
                )
                    : CardWidget(
                  label: labels[1],
                  color: color,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class InputPage extends StatefulWidget {
  @override
  _InputPageState createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  // List of colors to cycle through
  List<Color> colors = [
    Color(0xFF1C1F32), // Default dark background
    Colors.teal,
    Colors.purple,
    Colors.blueGrey,
  ];
  int colorIndex = 0; // Current color index
  String? selectedGender; // Track selected gender (Male/Female)

  // Function to change color
  void changeColor() {
    setState(() {
      colorIndex = (colorIndex + 1) % colors.length; // Cycle through colors
    });
  }

  // Function to select male
  void selectMale() {
    setState(() {
      selectedGender = 'Male';
    });
  }

  // Function to select female
  void selectFemale() {
    setState(() {
      selectedGender = 'Female';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BMI Calculator'),
      ),
      body: BMILayoutContainer(
        color: colors[colorIndex],
        onColorChange: changeColor,
        selectedGender: selectedGender,
        onMaleSelect: selectMale,
        onFemaleSelect: selectFemale,
      ),
    );
  }
}