import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker_mvp/providers/app_state.dart';
import 'package:habit_tracker_mvp/screens/biometric_auth_screen.dart';
import 'package:habit_tracker_mvp/screens/home_screen.dart';
import 'package:habit_tracker_mvp/screens/login_screen.dart';
import 'package:provider/provider.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _hasAuthenticated = false;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (snapshot.hasData) {
          // User is logged in
          if (appState.biometricEnabled && !_hasAuthenticated) {
            return BiometricAuthScreen(
              onAuthenticated: () {
                setState(() {
                  _hasAuthenticated = true;
                });
              },
            );
          }
          return const HomeScreen();
        }
        
        return const LoginScreen();
      },
    );
  }
}
