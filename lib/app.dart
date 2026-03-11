import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'theme/app_theme.dart';

class ArabicLearningApp extends StatelessWidget {
  const ArabicLearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'abaaba',
      theme: AppTheme.lightTheme,
      home: const HomePage(),
    );
  }
}
