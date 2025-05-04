import 'package:flutter/material.dart';

class InputPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BMI Calculator'),
      ),
      body: Column(
        children: [
          // First Row: Two columns with containers
          Expanded(
            child: Row(
              children: [
                // First column container
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xFF1C1F32), // Dark background
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'Weight (kg)', // Placeholder for weight input
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
                // Second column container
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xFF1C1F32),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'Height (cm)', // Placeholder for height input
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Second Row: One container
          Expanded(
            child: Container(
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color(0xFF1C1F32),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  'Calculate Button', // Placeholder for button
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
          // Third Row: Two columns with containers
          Expanded(
            child: Row(
              children: [
                // First column container
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xFF1C1F32),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'BMI Value', // Placeholder for BMI display
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
                // Second column container
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xFF1C1F32),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'Category', // Placeholder for category
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Fourth Row: Stateful widget
          BMIResultWidget(),
        ],
      ),
    );
  }
}

// Stateful widget for the fourth Expanded widget
class BMIResultWidget extends StatefulWidget {
  @override
  _BMIResultWidgetState createState() => _BMIResultWidgetState();
}

class _BMIResultWidgetState extends State<BMIResultWidget> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Color(0xFF1C1F32),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            'Result Area', // Placeholder for dynamic result
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}