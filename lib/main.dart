import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo_app/auth/pages/login.dart';
import 'package:todo_app/auth/pages/register.dart';
import 'package:todo_app/welcome.dart';

import 'dashboard/pages/dashbord_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://rvyxffaeohfznduophya.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ2eXhmZmFlb2hmem5kdW9waHlhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA2NDg3NDUsImV4cCI6MjA4NjIyNDc0NX0.o8wIKgk172F9mQRJc_HsJU-5oLVkQI2IchcH3B7TZCs',
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoading = true;
  Widget? _initialScreen;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    try {
      // Attendre un peu pour que Supabase initialise complètement
      await Future.delayed(const Duration(milliseconds: 100));

      final session = Supabase.instance.client.auth.currentSession;
      final user = Supabase.instance.client.auth.currentUser;

      if (session != null && user != null) {
        // L'utilisateur est connecté, aller au dashboard
        setState(() {
          _initialScreen = const DashboardPage();
          _isLoading = false;
        });
      } else {
        // L'utilisateur n'est pas connecté, aller à la page d'accueil
        setState(() {
          _initialScreen = Welcome();
          _isLoading = false;
        });
      }
    } catch (e) {
      // En cas d'erreur, aller à la page d'accueil
      setState(() {
        _initialScreen = Welcome();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Afficher un écran de chargement pendant la vérification
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: const Locale('fr', 'FR'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('fr', 'FR'), Locale('en', 'US')],
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: const Color(0xFF21B6EC)),
          ),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('fr', 'FR'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('fr', 'FR'), Locale('en', 'US')],
      home: _initialScreen,
      routes: {
        '/register': (context) => const RegisterPage(),
        '/login': (context) => const LoginPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/welcome': (context) => Welcome(),
      },
    );
  }
}
