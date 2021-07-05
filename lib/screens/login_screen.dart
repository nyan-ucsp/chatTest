import 'dart:async';
import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_chat_apk/Components/utils.dart';
import 'package:simple_chat_apk/Components/irra_xmpp_stone.dart';
import 'package:simple_chat_apk/Components/utils_widget.dart';
import 'package:simple_chat_apk/screens/main_screen.dart';
import 'package:simple_chat_apk/services/navigation_service.dart';
import 'package:simple_chat_apk/services/shared_perferences_service.dart';
import 'package:xmpp_stone/xmpp_stone.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final passwordFocus = FocusNode();
  final portFocus = FocusNode();
  late String? username, password, port;

  @override
  void dispose() {
    passwordFocus.dispose();
    portFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Center(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Image.asset(
                      'resources/images/app_icon.png',
                      width: 100,
                      height: 100,
                    ),
                    UtilsWidget.circularBorderTextFormField(
                      hint: 'username',
                      textInputType: TextInputType.name,
                      onSave: (value) {
                        username = value;
                      },
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          return null;
                        } else {
                          return 'Please enter username';
                        }
                      },
                      onFieldSubmitted: (value) {
                        FocusScope.of(context).requestFocus(passwordFocus);
                      },
                    ),
                    textFieldSpacer(),
                    UtilsWidget.circularBorderTextFormField(
                      hint: 'password',
                      textInputType: TextInputType.visiblePassword,
                      obscureText: true,
                      onSave: (value) {
                        password = value;
                      },
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          return null;
                        } else {
                          return 'Please enter password';
                        }
                      },
                      onFieldSubmitted: (value) {
                        FocusScope.of(context).requestFocus(portFocus);
                      },
                    ),
                    textFieldSpacer(),
                    UtilsWidget.circularBorderTextFormField(
                      focusNode: portFocus,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                      ],
                      hint: 'port (Default 5222)',
                      textInputType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      onSave: (value) {
                        port = value!.isEmpty ? '5222' : value;
                      },
                      onFieldSubmitted: (value) async {
                        await _loginClick();
                      },
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await _loginClick();
                      },
                      child: Text('Login'),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.blue),
                        elevation: MaterialStateProperty.all(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget textFieldSpacer() {
    return SizedBox(
      height: 8,
    );
  }

  Future<void> _loginClick() async {
    if (FocusScope.of(context).hasFocus) FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      BotToast.showLoading();
      _formKey.currentState!.save();
      int intPort = int.parse(port!);
      Utils.print(print: 'Jid.fromFullJid');
      Jid jid = Jid.fromFullJid(username!);
      XmppAccountSettings xmppAccount = XmppAccountSettings(
        username!,
        jid.local,
        jid.domain,
        password!,
        intPort,
      );

      IrraXmppStone.login(
          xmppAccount: xmppAccount,
          success: () {
            SharedPreferencesService.setXmppAccount(
                username: username!, password: password!, port: intPort);
            BotToast.closeAllLoading();
            NavigationService.pushReplacementNamed(
              RouteName.mainScreen,
              argument: MainScreen(
                xmppAccount: xmppAccount,
              ),
            );
          },
          fail: () {
            BotToast.closeAllLoading();
            BotToast.showText(text: 'Login Fail');
          });
    }
  }
}

// class ExampleConnectionStateChangedListener
//     implements xmpp.ConnectionStateChangedListener {
//   late xmpp.Connection _connection;
//   late xmpp.MessagesListener _messagesListener;

//   StreamSubscription<String>? subscription;

//   ExampleConnectionStateChangedListener(
//       xmpp.Connection connection, xmpp.MessagesListener messagesListener) {
//     _connection = connection;
//     _messagesListener = messagesListener;
//     _connection.connectionStateStream.listen(onConnectionStateChanged);
//   }

//   @override
//   void onConnectionStateChanged(xmpp.XmppConnectionState state) {
//     Utils.print(
//         print:
//             'Connection State: ${xmpp.XmppConnectionState.values[state.index]}');
//     if (state == xmpp.XmppConnectionState.Ready) {
//       Utils.print(print: 'Connection State: Connected');

//       var vCardManager = xmpp.VCardManager(_connection);
//       vCardManager.getSelfVCard().then((vCard) {
//         Utils.print(print: 'Your info: ${vCard.buildXmlString()}');
//       });
//       var messageHandler = xmpp.MessageHandler.getInstance(_connection);
//       var rosterManager = xmpp.RosterManager.getInstance(_connection);
//       messageHandler.messagesStream.listen(_messagesListener.onNewMessage);
//       sleep(const Duration(seconds: 1));
//       var receiver = 'dev2@chat.nhtpgroup.com';
//       var receiverJid = xmpp.Jid.fromFullJid(receiver);
//       rosterManager.addRosterItem(xmpp.Buddy(receiverJid)).then((result) {
//         if (result.description != null) {
//           Utils.print(print: 'add roster: ${result.description!}');
//         }
//       });
//       sleep(const Duration(seconds: 1));
//       vCardManager.getVCardFor(receiverJid).then((vCard) {
//         Utils.print(print: 'Receiver info: ${vCard.buildXmlString()}');

//         if (vCard.image != null) {
//           var file = File('test456789.jpg')
//             ..writeAsBytesSync(image.encodeJpg(vCard.image!));
//           Utils.print(print: 'IMAGE SAVED TO: ${file.path}');
//         }
//       });
//       var presenceManager = xmpp.PresenceManager.getInstance(_connection);
//       presenceManager.presenceStream.listen(onPresence);
//     }
//   }

//   void onPresence(xmpp.PresenceData event) {
//     Utils.print(
//         print: 'presence Event from ' +
//             event.jid!.fullJid! +
//             ' PRESENCE: ' +
//             event.showElement.toString());
//   }
// }

// Stream<String> getConsoleStream() {
//   return Console.adapter.byteStream().map((bytes) {
//     var str = ascii.decode(bytes);
//     str = str.substring(0, str.length - 1);
//     Utils.print(print: 'Get Console Stream: $str');
//     return str;
//   });
// }

// class ExampleMessagesListener implements xmpp.MessagesListener {
//   @override
//   void onNewMessage(xmpp.MessageStanza? message) {
//     if (message!.body != null) {
//       Utils.print(print: 'New Message');
//       Utils.print(
//           print:
//               'New Message from {color.blue}${message.fromJid!.userAtDomain}{color.end} message: {color.red}${message.body}{color.end}');
//     }
//   }
// }
