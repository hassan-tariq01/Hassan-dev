import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'providers/task_provider.dart';
import 'providers/student_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/constants.dart';
import 'dart:developer' as developer;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await supabase.Supabase.initialize(
      url: 'https://ruzqhwzvssunqsujymui.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ1enFod3p2c3N1bnFzdWp5bXVpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDczNzkzMTQsImV4cCI6MjA2Mjk1NTMxNH0.RO-VqBkCDbwhRU1BC8j1PZdAcPPEwN3IpfqbtCXTXCM',
    );
    developer.log('Supabase initialized successfully');
  } catch (e) {
    developer.log('Supabase init failed: $e');
  }
  developer.log('Admin App running successfully at ${DateTime.now()}');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => StudentProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Task Management System - Admin',
        theme: ThemeData(
          primaryColor: AppConstants.primaryColor,
          scaffoldBackgroundColor: Colors.transparent,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.white),
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          cardTheme: CardTheme(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 5,
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}