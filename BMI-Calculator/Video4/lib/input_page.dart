import 'package:flutter/material.dart';

// Reusable widget for the entire BMI layout
class BMILayoutContainer extends StatelessWidget {
  final Color color; // Container color
  final VoidCallback onColorChange; // Callback for color change

  BMILayoutContainer({required this.color, required this.onColorChange});

  // Row configuration: label(s) and optional tap callback
  final List<Map<String, dynamic>> rowConfigs = [
    {'labels': ['Weight (kg)', 'Height (cm)']}, // Two columns
    {'labels': ['Calculate Button']}, // Single card
    {'labels': ['BMI Value', 'Category']}, // Two columns
    {'labels': ['Result Area']}, // Single card
    {'labels': ['Change Color'], 'onTap': true}, // Single card with tap
  ];

  @override
  Widget build(BuildContext context) {
    Widget card(String label) {
      return Container(
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color, // Use dynamic color
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(fontSize: 18, color: Colors.white), // White text for contrast
          ),
        ),
      );
    }

    return Column(
      children: rowConfigs.map((config) {
        final labels = config['labels'] as List<String>;
        final onTap = config['onTap'] == true ? onColorChange : null;

        return Expanded(
          child: labels.length == 1
              ? GestureDetector(
            onTap: onTap,
            child: card(labels[0]),
          )
              : Row(
            children: [
              Expanded(child: card(labels[0])),
              Expanded(child: card(labels[1])),
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

  // Function to change color
  void changeColor() {
    setState(() {
      colorIndex = (colorIndex + 1) % colors.length; // Cycle through colors
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
      ),
    );
  }
}