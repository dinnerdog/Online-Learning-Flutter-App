import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:test1/features/new/router.dart';
import 'package:test1/features/new/welcome/ui/welcome.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  
    await Firebase.initializeApp(
);
  

  runApp(MyApp());
}


class AppColors {
  static const Color mainColor = Color(0xFFEF7674);
  static const Color secondaryColor = Color(0xFFFBF4F4);
  static const Color accentColor = Color(0xFFEB5E52);

  static const Color darkMainColor = Color.fromARGB(255, 66, 57, 113);
  static const Color darkSecondaryColor = Color.fromARGB(255, 24, 23, 23);
  static const Color darkAccentColor = Color.fromARGB(255, 32, 17, 141);
}

final ThemeData lightTheme = ThemeData.light().copyWith(
  primaryColor: AppColors.mainColor,
  cardColor: AppColors.secondaryColor,
);

final ThemeData darkTheme = ThemeData.dark().copyWith(
    primaryColor: AppColors.darkMainColor,
    cardColor: AppColors.darkSecondaryColor);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kind hearts',
      theme: lightTheme,
      darkTheme: darkTheme,
      onGenerateRoute: AppRouter.generateRoute,
      home: Welcome(),
    );
  }
}
