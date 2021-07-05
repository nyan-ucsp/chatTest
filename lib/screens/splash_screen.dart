import 'package:flutter/material.dart';
import 'package:simple_chat_apk/screens/main_screen.dart';
import 'package:simple_chat_apk/services/navigation_service.dart';
import 'package:simple_chat_apk/services/shared_perferences_service.dart';
import 'package:xmpp_stone/xmpp_stone.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    init();
    super.initState();
  }

  Future<void> init() async {
    await Future.delayed(Duration(seconds: 2), () async {
      XmppAccountSettings? xmppAccount =
          await SharedPreferencesService.getXmppAccount();
      if (xmppAccount == null) {
        NavigationService.pushReplacementNamed(RouteName.loginScrren);
      } else {
        NavigationService.pushReplacementNamed(RouteName.mainScreen,
            argument: MainScreen(xmppAccount: xmppAccount));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset('resources/images/splash_loading.gif'),
      ),
    );
  }
}
