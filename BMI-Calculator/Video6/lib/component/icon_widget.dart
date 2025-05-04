import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// Reusable card widget with icon and text
class CardWidget extends StatelessWidget {
  final String label; // Text to display
  final Color color; // Container color
  final bool isSelected; // Highlight for selected gender

  CardWidget({required this.label, required this.color, this.isSelected = false});

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
}