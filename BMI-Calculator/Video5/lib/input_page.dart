import 'package:flutter/material.dart';

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

  // Map labels to icons
  IconData getIconForLabel(String label) {
    switch (label) {
      case 'Male':
        return Icons.male; // Male icon
      case 'Female':
        return Icons.female; // Female icon
      case 'Weight (kg)':
        return Icons.fitness_center; // Weight icon
      case 'Height (cm)':
        return Icons.height; // Height icon
      case 'Calculate Button':
        return Icons.calculate; // Calculate icon
      case 'BMI Value':
        return Icons.assessment; // BMI icon
      case 'Category':
        return Icons.category; // Category icon
      case 'Change Color':
        return Icons.color_lens; // Color change icon
      default:
        return Icons.help; // Fallback icon
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget card(String label) {
      final isGenderCard = label == 'Male' || label == 'Female';
      final isSelected = isGenderCard && selectedGender == label;

      return Container(
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color, // Use dynamic color
          borderRadius: BorderRadius.circular(10),
          border: isSelected ? Border.all(color: Colors.white, width: 2) : null, // Highlight selected gender
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                getIconForLabel(label),
                size: 40,
                color: Colors.white, // White icon for contrast
              ),
              SizedBox(height: 10), // Space between icon and text
              Text(
                label,
                style: TextStyle(fontSize: 18, color: Colors.white), // White text for contrast
              ),
            ],
          ),
        ),
      );
    }

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
            child: card(labels[0]),
          )
              : Row(
            children: [
              Expanded(
                child: isInteractive && index == 0
                    ? GestureDetector(
                  onTap: onMaleSelect,
                  child: card(labels[0]),
                )
                    : card(labels[0]),
              ),
              Expanded(
                child: isInteractive && index == 0
                    ? GestureDetector(
                  onTap: onFemaleSelect,
                  child: card(labels[1]),
                )
                    : card(labels[1]),
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