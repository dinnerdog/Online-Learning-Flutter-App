import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:test1/features/new/router.dart';
import 'package:test1/features/new/welcome/ui/welcome.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
      apiKey: 'AIzaSyCPk0xy3Ce6dfgXoR7541x6ce9vDjg7wOU',
      appId: '1:554131863030:android:44abab06d59e71183b83d7',
      messagingSenderId: '554131863030',
      projectId: 'flutter-392e6',
      storageBucket: 'flutter-392e6.appspot.com',
    ));
  } else {
    await Firebase.initializeApp(
);
  }

  runApp(MyApp());
}

// {
//   "project_info": {
//     "project_number": "554131863030",
//     "project_id": "flutter-392e6",
//     "storage_bucket": "flutter-392e6.appspot.com"
//   },
//   "client": [
//     {
//       "client_info": {
//         "mobilesdk_app_id": "1:554131863030:android:44abab06d59e71183b83d7",
//         "android_client_info": {
//           "package_name": "com.example.test1"
//         }
//       },
//       "oauth_client": [],
//       "api_key": [
//         {
//           "current_key": "AIzaSyCPk0xy3Ce6dfgXoR7541x6ce9vDjg7wOU"
//         }
//       ],
//       "services": {
//         "appinvite_service": {
//           "other_platform_oauth_client": []
//         }
//       }
//     }
//   ],
//   "configuration_version": "1"
// }

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
