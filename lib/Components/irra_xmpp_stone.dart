import 'dart:async';

import 'package:simple_chat_apk/Components/utils.dart';
import 'package:xmpp_stone/xmpp_stone.dart';

class IrraXmppStone {
  static void login({
    required XmppAccountSettings xmppAccount,
    required Function success,
    required Function fail,
  }) {
    Utils.print(print: "IrraXmppStone Login");
    Connection connection = new Connection(xmppAccount);
    connection.connect();
    final loginStream = connection.connectionStateStream;
    late StreamSubscription loginConnectionSubScription;
    loginConnectionSubScription = loginStream.listen((state) {
      Utils.print(
          print:
              'Connection State: ${XmppConnectionState.values[state.index]}');
      if (state == XmppConnectionState.Authenticated) {
        connection.close();
        success();
        loginConnectionSubScription.cancel();
      } else if (state == XmppConnectionState.AuthenticationFailure) {
        fail();
        loginConnectionSubScription.cancel();
      }
    }, onDone: () {
      Utils.print(print: "IrraXmppStone Login Done");
      Utils.print(
          print: 'Connection authenticated: ${connection.authenticated}');
    }, onError: (error) {
      fail();
    });
  }
}

class IrraXmppStoneMessageListener implements MessagesListener {
  @override
  void onNewMessage(MessageStanza? message) {
    if (message!.body != null) {
      Utils.print(print: 'New Message');
      Utils.print(
          print:
              'New Message from ${message.fromJid!.userAtDomain}, message: ${message.body}');
    }
  }
}
