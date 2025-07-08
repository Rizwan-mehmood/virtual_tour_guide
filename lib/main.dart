// main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:uaetourguide/screens/splash_screen.dart';
import 'package:uaetourguide/providers/museum_provider.dart';
import 'package:uaetourguide/providers/firebase_provider.dart';
import 'package:uaetourguide/theme.dart';
import 'package:uaetourguide/services/local_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // lock orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // transparent status bar & nav bar styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // record last‑visited timestamp
  await LocalStorageService.saveLastVisitedTimestamp();

  // initialize Firebase
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MuseumProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => FirebaseProvider()..initialize()),
      ],
      child: MaterialApp(
        title: 'Louvre Abu Dhabi',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
}
