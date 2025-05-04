import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants.dart';
import 'card_type.dart';


// Reusable card widget with a slider and TextField for weight or height input
class SliderCardWidget extends StatelessWidget {
  final CardType type; // Card type (weight or height)
  final Color color; // Container color
  final double min; // Minimum slider value
  final double max; // Maximum slider value
  final double value; // Current slider value
  final TextEditingController controller; // Controller for TextField
  final ValueChanged<double>? onChanged; // Callback for slider/TextField changes

  SliderCardWidget({
    required this.type,
    required this.color,
    required this.min,
    required this.max,
    required this.value,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Sync controller with current value
    controller.text = value.toInt().toString();

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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    style: AppConstants.inputTextStyle,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: AppConstants.iconColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppConstants.iconColor.withOpacity(0.5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppConstants.iconColor),
                      ),
                    ),
                    onChanged: (text) {
                      final newValue = double.tryParse(text);
                      if (newValue != null && newValue >= min && newValue <= max) {
                        onChanged?.call(newValue);
                      }
                    },
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  type == CardType.weight ? 'kg' : 'cm',
                  style: AppConstants.unitTextStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}