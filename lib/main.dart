import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo_app/auth/pages/login.dart';
import 'package:todo_app/auth/pages/register.dart';
import 'package:todo_app/core/app_state.dart';
import 'package:todo_app/dashboard/services/notification_service.dart';
import 'package:todo_app/theme.dart';
import 'package:todo_app/welcome.dart';

import 'dashboard/pages/dashbord_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyDA1CtolZzOG70WVIcTxrNYDpHR0PgpBp0',
      appId: '1:588195192526:android:4a44527242f43491fbba9f',
      messagingSenderId: '588195192526',
      projectId: 'mediblock-49acd',
      storageBucket: 'mediblock-49acd.firebasestorage.app',
    ),
  );

  await Supabase.initialize(
    url: 'https://rvyxffaeohfznduophya.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ2eXhmZmFlb2hmem5kdW9waHlhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA2NDg3NDUsImV4cCI6MjA4NjIyNDc0NX0.o8wIKgk172F9mQRJc_HsJU-5oLVkQI2IchcH3B7TZCs',
  );

  // Initialiser les notifications
  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(MyApp(notificationService: notificationService));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.notificationService});

  final NotificationService notificationService;

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
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appThemeData(),
      locale: const Locale('fr', 'FR'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('fr', 'FR'), Locale('en', 'US')],
      home: ChangeNotifierProvider(
        create: (context) => AppState(),
        child: _initialScreen,
      ),
      routes: {
        '/register': (context) => const RegisterPage(),
        '/login': (context) => const LoginPage(),
        '/dashboard': (context) => ChangeNotifierProvider(
          create: (context) => AppState(),
          child: const DashboardPage(),
        ),
        '/welcome': (context) => Welcome(),
      },
    );
  }
}
