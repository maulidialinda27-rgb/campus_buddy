import 'package:flutter/material.dart';
import 'package:campus_buddy/core/theme/app_theme.dart';
import 'package:campus_buddy/features/home/presentation/pages/home_page.dart';

class CampusBuddyApp extends StatelessWidget {
  const CampusBuddyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CampusBuddy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}
