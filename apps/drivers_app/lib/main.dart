import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:drivers_app/firebase_options.dart';
import 'package:drivers_app/screens/authentication/splash_screen.dart';
import 'package:drivers_app/screens/authentication/driver_login_screen.dart';
import 'package:drivers_app/screens/authentication/driver_signup_screen.dart';
import 'package:drivers_app/screens/dashboard/driver_dashboard.dart';
import 'package:drivers_app/services/driver_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const DriverApp());
}

class DriverApp extends StatefulWidget {
  const DriverApp({Key? key}) : super(key: key);

  @override
  State<DriverApp> createState() => _DriverAppState();
}

class _DriverAppState extends State<DriverApp> {
  late DriverNotificationService _notificationService;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    _notificationService = DriverNotificationService();
    await _notificationService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uber Clone - Driver',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.deepPurple.shade600,
          foregroundColor: Colors.white,
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const DriverLoginScreen(),
        '/signup': (context) => const DriverSignupScreen(),
        '/dashboard': (context) => const DriverDashboard(),
      },
    );
  }
}
