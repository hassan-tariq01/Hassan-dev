import 'package:flutter/material.dart';
import 'card_type.dart';

// Reusable card widget with icon, text, and gesture detection
class CardWidget extends StatelessWidget {
  final CardType type; // Card type (enum)
  final Color color; // Container color
  final bool isSelected; // Highlight for selected gender
  final VoidCallback? onTap; // Optional tap callback

  CardWidget({
    required this.type,
    required this.color,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Handle tap if callback is provided
      child: Container(
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
                type.icon,
                size: 40,
                color: Colors.white, // White icon for contrast
              ),
              SizedBox(height: 10), // Space between icon and text
              Text(
                type.displayText,
                style: TextStyle(fontSize: 18, color: Colors.white), // White text for contrast
              ),
            ],
          ),
        ),
      ),
    );
  }
}