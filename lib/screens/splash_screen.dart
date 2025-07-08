// screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uaetourguide/screens/home_screen.dart';

import 'login_screen.dart';
import 'welcome_screen.dart';
import '../widgets/custom_bottom_nav.dart'; // contains MainNavigationScreen
import '../providers/firebase_provider.dart';
import '../theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeIn = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.65, curve: Curves.easeInOut),
      ),
    );
    _scale = Tween(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.65, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();

    // After splash, decide where to go
    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        await _navigateNext();
      }
    });
  }

  Future<void> _navigateNext() async {
    final prefs = await SharedPreferences.getInstance();
    final seenWelcome = prefs.getBool('seenWelcome') ?? false;

    if (!seenWelcome) {
      // First time → show WelcomeScreen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
      return;
    }

    // Otherwise user already saw welcome → go auth flow
    final firebaseProvider = Provider.of<FirebaseProvider>(
      context,
      listen: false,
    );
    await firebaseProvider.initialize();

    if (firebaseProvider.currentUser == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder:
                  (context, child) => Opacity(
                    opacity: _fadeIn.value,
                    child: Transform.scale(scale: _scale.value, child: child),
                  ),
              child: Column(
                children: [
                  // Logo
                  Image.network(
                    'https://logowik.com/content/uploads/images/louvre-abu-dhabi7781.jpg',
                    height: 120,
                    errorBuilder:
                        (_, __, ___) => const Icon(
                          Icons.museum_outlined,
                          size: 120,
                          color: AppTheme.primaryColor,
                        ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'LOUVRE ABU DHABI',
                    style: AppTheme.textTheme.displayMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'See Humanity in a New Light',
                    style: AppTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.textSecondaryColor,
                      letterSpacing: 0.5,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            AnimatedBuilder(
              animation: _controller,
              builder:
                  (_, __) => Opacity(
                    opacity: _controller.value,
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryColor,
                      ),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
