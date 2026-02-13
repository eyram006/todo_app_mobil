import 'package:flutter/material.dart';
import 'package:todo_app/welcome.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://rvyxffaeohfznduophya.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ2eXhmZmFlb2hmem5kdW9waHlhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA2NDg3NDUsImV4cCI6MjA4NjIyNDc0NX0.o8wIKgk172F9mQRJc_HsJU-5oLVkQI2IchcH3B7TZCs',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
        home: Welcome());
  }
}
