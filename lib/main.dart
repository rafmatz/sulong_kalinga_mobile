import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sulong_kalinga_mobile/screens/auth/login_screen.dart';
import 'package:sulong_kalinga_mobile/screens/home/home_screen.dart';
import 'package:sulong_kalinga_mobile/wrappers/auth_wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// --- Place the background handler at the top level ---
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Handle background notification
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'PASTE_FROM_SUPABASE', // <-- paste from dashboard
    anonKey: 'PASTE_FROM_SUPABASE', // <-- paste from dashboard
  );
  await Firebase.initializeApp();

  // FCM setup
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission();
  String? token = await messaging.getToken();
  print('FCM Token: $token');
  // TODO: Store this token in Supabase for the user

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    // Handle foreground notification
    print('Received a foreground message: ${message.notification?.title}');
  });

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sulong Kalinga',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}