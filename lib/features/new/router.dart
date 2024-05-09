import 'package:flutter/material.dart';
import 'package:test1/features/new/games/ui/games.dart';
import 'package:test1/features/new/login/ui/login.dart';
import 'package:test1/features/new/profile/ui/profile.dart';
import 'package:test1/features/new/sign_up/ui/sign_up.dart';
import 'package:test1/features/new/welcome/ui/welcome.dart';

class AppRouter {
  static const String home = '/';
  static const String welcome = '/welcome';
  static const String signIn = '/login';
  static const String signUp = '/sign_up';
  static const String course = '/course';
  static const String activity = '/activity';
  static const String activity_add = '/activity/activity_add';
  static const String contacts = '/contacts';
  static const String profile = '/profile';
  static const String games = '/games';
  

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // case home:
      //   return MaterialPageRoute(builder: (_) => Home());
      case welcome:
        return MaterialPageRoute(builder: (_) => Welcome());
      case signIn:
        return MaterialPageRoute(builder: (_) => Login());
      case signUp:
        return MaterialPageRoute(builder: (_) => SignUp());
      // case course:
      //   return MaterialPageRoute(builder: (_) => Course());
      // case activity:
      //   return MaterialPageRoute(builder: (_) => Activity( ));
      // case activity_add:
      //   return MaterialPageRoute(builder: (_) => ActivityAdd());
      // case contacts:
      //   return MaterialPageRoute(builder: (_) => Contacts());
      // case games:
        // return MaterialPageRoute(builder: (_) => Games());
      case profile:
        return MaterialPageRoute(builder: (_) => Profile());

      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                    child: Text('No route defined for ${settings.name}'),
                  ),
                ));
    }
  }
}
