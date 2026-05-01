import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const ProgressEngineApp());
}

class ProgressEngineApp extends StatelessWidget {
  const ProgressEngineApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF27B3B0);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Progress Engine',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF07111F),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF0E1A2A),
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(
              color: Color(0x1FFFFFFF),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF0D1726),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0x1FFFFFFF)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0x1FFFFFFF)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: seedColor),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
