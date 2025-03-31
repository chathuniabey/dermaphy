import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'auth/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'widgets/bottom_nav.dart'; // ✅ Import your bottom nav

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skin Disease Prediction',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
      primarySwatch: Colors.teal,
      scaffoldBackgroundColor: Color(0xFF008080)),
      home: const AuthGate(), // 🔐 Show login or main app
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const BottomNav(); // ✅ Main app
        } else {
          return const LoginPage(); // 🔒 Not logged in
        }
      },
    );
  }
}

