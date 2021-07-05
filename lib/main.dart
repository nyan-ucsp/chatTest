import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:simple_chat_apk/services/navigation_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: BotToastInit(),
      navigatorKey: NavigationService.navigationKey,
      navigatorObservers: [BotToastNavigatorObserver()],
      title: 'Simple Chat Apk',
      theme: ThemeData(
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      initialRoute: RouteName.splashScreen,
      onGenerateRoute: NavigationService.generateRoute,
    );
  }
}
