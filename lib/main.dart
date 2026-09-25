import 'package:flutter/material.dart';
import 'screens/game_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HigherLowerApp());
}

class HigherLowerApp extends StatelessWidget {
  const HigherLowerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Higher or Lower - Card Game',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      home: const GameScreen(),
    );
  }
}
