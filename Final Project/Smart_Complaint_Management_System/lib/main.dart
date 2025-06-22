import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'src/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL', // Replace with your Supabase project URL
    anonKey: 'YOUR_SUPABASE_ANON_KEY', // Replace with your Supabase anon key
  );

  runApp(const MyApp());
}