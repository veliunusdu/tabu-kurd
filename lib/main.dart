import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const KurdishTabooApp());
}

class KurdishTabooApp extends StatelessWidget {
  const KurdishTabooApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TabuKurd',
      theme: ThemeData(
        primarySwatch: Colors.red,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF228B22), // Kurdish flag green
          secondary: const Color(0xFFFFD700), // Kurdish flag yellow
        ),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF228B22),
          foregroundColor: Colors.white,
        ),
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
