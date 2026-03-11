import 'package:flutter/material.dart';
import 'screens/main_layout.dart';

// --- NOU: Aici e telecomanda noastră globală pentru Dark Mode ---
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() {
  runApp(const QuizGeniusApp());
}

class QuizGeniusApp extends StatelessWidget {
  const QuizGeniusApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder "ascultă" telecomanda și redesenează ecranul când apăsăm pe buton
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'QuizGenius',
          
          // Cum arată aplicația pe timp de ZI (Light Mode)
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple, 
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          
          // Cum arată aplicația pe timp de NOAPTE (Dark Mode)
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple, 
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          
          // Tema actuală aleasă
          themeMode: currentMode, 
          home: const MainLayout(), 
        );
      },
    );
  }
}