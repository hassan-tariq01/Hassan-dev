import 'package:flutter/material.dart';

void main() => runApp(BMICalculator());

class BMICalculator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color(0xFF0A0E21),
        scaffoldBackgroundColor: Color(0xFF0A0E21),
        colorScheme: ColorScheme.dark().copyWith(
          primary: Color(0xFF0A0E21),
          surface: Color(0xFF0A0E21),
        ),
      ),
      home: InputPage(),
    );
  }
}

class InputPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BMI Calculator'),
      ),
      body: Center(
        child: Text('Input Page'),
      ),
    );
  }
}