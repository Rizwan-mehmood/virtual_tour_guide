import 'package:flutter/material.dart';
import '../providers/firebase_provider.dart';
import 'package:provider/provider.dart';
import '../screens/login_screen.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final firebaseProvider = Provider.of<FirebaseProvider>(context);

    if (firebaseProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (firebaseProvider.currentUser == null) {
      return const LoginScreen();
    }

    return child;
  }
}
