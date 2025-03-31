import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/bottom_nav.dart'; // ✅ correct location of BottomNav
import 'login_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<bool> _isUserValid() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      await user.reload(); // ⬅️ Forces Firebase to refresh user info
      return FirebaseAuth.instance.currentUser != null;
    } catch (e) {
      await FirebaseAuth.instance.signOut(); // User deleted remotely
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isUserValid(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
       return snapshot.data! ? const BottomNav() : const LoginPage();
      },
    );
  }
}

