import 'package:flutter/material.dart';
import 'card_type.dart';


// Reusable card widget with a slider for weight or height input
class SliderCardWidget extends StatelessWidget {
  final CardType type; // Card type (weight or height)
  final Color color; // Container color
  final double min; // Minimum slider value
  final double max; // Maximum slider value
  final double value; // Current slider value
  final ValueChanged<double>? onChanged; // Callback for slider changes

  SliderCardWidget({
    required this.type,
    required this.color,
    required this.min,
    required this.max,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context, dynamic AppConstants) {
    return Container(
      margin: AppConstants.containerMargin,
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppConstants.containerBorderRadius,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            type.icon,
            size: AppConstants.iconSize,
            color: AppConstants.iconColor,
          ),
          SizedBox(height: AppConstants.iconTextSpacing),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).toInt(), // 1-unit increments
            activeColor: AppConstants.iconColor,
            inactiveColor: AppConstants.iconColor.withOpacity(0.3),
            onChanged: onChanged,
          ),
          Text(
            '${value.toInt()} ${type == CardType.weight ? 'kg' : 'cm'}',
            style: AppConstants.sliderTextStyle,
          ),
        ],
      ),
    );
  }
}