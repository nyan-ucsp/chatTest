import 'package:flutter/material.dart';
import 'package:simple_chat_apk/screens/chat_screen.dart';
import 'package:simple_chat_apk/screens/login_screen.dart';
import 'package:simple_chat_apk/screens/main_screen.dart';
import 'package:simple_chat_apk/screens/splash_screen.dart';

class RouteName {
  static const String splashScreen = '/';
  static const String loginScrren = '/loginScreen';
  static const String mainScreen = '/mainScreen';
  static const String chatScreen = '/chatScreen';
}

class NavigationService {
  static final GlobalKey<NavigatorState> navigationKey =
      GlobalKey<NavigatorState>();

  static Future<dynamic> pushNamed(
    String routeName, {
    Object? argument,
  }) {
    return navigationKey.currentState!
        .pushNamed(routeName, arguments: argument);
  }

  static Future<dynamic> pushReplacementNamed(
    String routeName, {
    Object? argument,
  }) {
    return navigationKey.currentState!
        .pushReplacementNamed(routeName, arguments: argument);
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteName.splashScreen:
        return MaterialPageRoute(
          builder: (_) => SplashScreen(),
        );
      case RouteName.loginScrren:
        return MaterialPageRoute(
          builder: (_) => LoginScreen(),
        );
      case RouteName.mainScreen:
        final MainScreen args = settings.arguments as MainScreen;
        return MaterialPageRoute(
          builder: (_) => MainScreen(
            xmppAccount: args.xmppAccount,
          ),
        );
      case RouteName.chatScreen:
        final ChatScreen args = settings.arguments as ChatScreen;
        return MaterialPageRoute(
          builder: (_) => ChatScreen(
            reciverBuddy: args.reciverBuddy,
            xmppAccount: args.xmppAccount,
            connection: args.connection,
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline_outlined,
                    color: Colors.red,
                    size: 50,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "404 not found",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Route name",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "${settings.name}",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }
}
