import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simple_chat_apk/Components/utils.dart';
import 'package:simple_chat_apk/Components/irra_xmpp_stone.dart';
import 'package:simple_chat_apk/Components/utils_widget.dart';
import 'package:simple_chat_apk/screens/chat_screen.dart';
import 'package:simple_chat_apk/services/navigation_service.dart';
import 'package:simple_chat_apk/services/shared_perferences_service.dart';
import 'package:xmpp_stone/xmpp_stone.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key, required this.xmppAccount}) : super(key: key);
  final XmppAccountSettings xmppAccount;
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with RestorationMixin {
  RestorableBool _loading = RestorableBool(true);
  late Connection _connection;
  StreamSubscription? _connectionSubscription;
  late MessagesListener _messagesListener;
  late MessageHandler _messageHandler;
  StreamSubscription? _messageStreamSuscription;
  late PresenceManager _presenceManager;
  StreamSubscription? _persenceStreamSubscription;
  StreamSubscription? _subscriptionStreamSubscription;
  late RosterManager _rosterManager;
  StreamSubscription? _rsoterStreamStreamSubscription;
  late MessageArchiveManager _meeageAchrieveManager;
  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  void dispose() {
    print('main dispose');
    _loading.dispose();
    if (_connection.isOpened()) {
      _connection.close();
    }
    if (_connectionSubscription != null) {
      _connectionSubscription?.cancel();
    }
    if (_persenceStreamSubscription != null) {
      _persenceStreamSubscription?.cancel();
    }
    if (_rsoterStreamStreamSubscription != null) {
      _rsoterStreamStreamSubscription?.cancel();
    }
    if (_messageStreamSuscription != null) {
      _messageStreamSuscription?.cancel();
    }
    if (_subscriptionStreamSubscription != null) {
      _subscriptionStreamSubscription?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              PresenceData presenceData = PresenceData(
                  PresenceShowElement.AWAY, "away", widget.xmppAccount.fullJid);
              _presenceManager.sendPresence(presenceData);
              // _persenceStreamSubscription?.cancel();
            },
            icon: Icon(Icons.check),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                widget.xmppAccount.username,
              ),
              accountEmail: Text(
                widget.xmppAccount.name,
              ),
              currentAccountPicture: Stack(
                alignment: AlignmentDirectional.bottomEnd,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Image.asset(
                      'resources/images/app_icon.png',
                      width: 80,
                      height: 80,
                    ),
                  ),
                  _loading.value
                      ? Container()
                      : accountStatusWidget(
                          _presenceManager.selfPresence.jid,
                        ),
                ],
              ),
            ),
            ListTile(
              title: Text(
                'Settings',
              ),
              leading: const Icon(Icons.settings),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(
                'Logout',
              ),
              leading: const Icon(Icons.logout),
              onTap: () async {
                Navigator.pop(context);
                await SharedPreferencesService.deleteXmppAccount();
                NavigationService.pushReplacementNamed(RouteName.loginScrren);
              },
            ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: _loading.value
                ? Center(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : StreamBuilder<List<Buddy>>(
                    stream: _rosterManager.rosterStream,
                    builder: (context, snapshot) {
                      print(snapshot.connectionState);
                      if (snapshot.hasData) {
                        List<Buddy> buddyList = snapshot.data ?? [];
                        return ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: buddyList.length,
                          itemBuilder: (context, index) {
                            _presenceManager
                                .askDirectPresence(buddyList[index].jid);
                            return ListTile(
                              onTap: () {
                                // _presenceManager.subscribe(buddyList[index].jid),
                                NavigationService.pushNamed(
                                  RouteName.chatScreen,
                                  argument: ChatScreen(
                                    reciverBuddy: buddyList[index],
                                    xmppAccount: widget.xmppAccount,
                                    connection: _connection,
                                  ),
                                );
                              },
                              contentPadding: EdgeInsets.all(8),
                              leading: Stack(
                                alignment: AlignmentDirectional.bottomEnd,
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.black12,
                                    child: Image.asset(
                                      'resources/images/app_icon.png',
                                      width: 60,
                                      height: 60,
                                    ),
                                  ),
                                  accountStatusWidget(
                                    buddyList[index].jid,
                                  ),
                                ],
                              ),
                              title: Text(buddyList[index].jid.local),
                              subtitle: Text(buddyList[index].jid.fullJid),
                            );
                          },
                        );
                      } else {
                        return Center(
                          child: CupertinoActivityIndicator(),
                        );
                      }
                    },
                  ),
          ),
        ),
      ),
    );
  }

  void init() {
    Log.logLevel = LogLevel.DEBUG;
    Log.logXmpp = false;
    _connection = Connection.getInstance(widget.xmppAccount);
    _connection.connect();
    _messagesListener = IrraXmppStoneMessageListener();
    _connectionSubscription =
        _connection.connectionStateStream.listen((connectionState) {
      print(connectionState);
      if (connectionState == XmppConnectionState.AuthenticationFailure) {
        SharedPreferencesService.deleteXmppAccount();
        NavigationService.pushReplacementNamed(RouteName.loginScrren);
      } else if (connectionState == XmppConnectionState.Ready) {
        _presenceManager = PresenceManager.getInstance(_connection);
        PresenceData presenceData = PresenceData(
            PresenceShowElement.CHAT, "available", widget.xmppAccount.fullJid);
        _presenceManager.sendPresence(presenceData);
        _rosterManager = RosterManager.getInstance(_connection);
        _messageHandler = MessageHandler.getInstance(_connection);
        _meeageAchrieveManager = _connection.getMamModule();
        _messageStreamSuscription = _messageHandler.messagesStream
            .listen(_messagesListener.onNewMessage);
        // _rsoterStreamStreamSubscription =
        //     _rosterManager.rosterStream.listen((rosterList) {
        //   rosterList.forEach((buddy) {
        //     Utils.print(
        //         print: "Buddy  accountJid: ${buddy.accountJid.fullJid}");
        //     Utils.print(print: "Buddy jid: ${buddy.jid.fullJid}");
        //     Utils.print(print: "Buddy name: ${buddy.name}");
        //     Utils.print(
        //         print: "Buddy subscriptionType: ${buddy.subscriptionType}");
        //     print('\n');
        //   });
        // }, onDone: () {
        //   print('roster stream done');
        // }, onError: (error) {
        //   print("Roster Error : $error");
        // });
        _persenceStreamSubscription =
            _presenceManager.presenceStream.listen((presence) {
          if (presence.jid == _presenceManager.selfPresence.jid) {
            setState(() {
              _presenceManager.selfPresence = presence;
            });
          }
          Utils.print(print: 'Presence Status ${presence.status}');
          Utils.print(
              print:
                  'Presence event from ${presence.jid.fullJid + ' PRESENCE: ' + presence.showElement.toString()}');
        });
        _subscriptionStreamSubscription =
            _presenceManager.subscriptionStream.listen((streamEvent) {
          Utils.print(
              print: 'Presence Manager STREAM EVENT Type: ${streamEvent.type}');
          if (streamEvent.type == SubscriptionEventType.REQUEST) {
            Utils.print(print: 'Stream Event JID: ${streamEvent.jid}');
            _presenceManager.acceptSubscription(streamEvent.jid);
          }
        });
        setState(() {
          _loading.value = false;
        });
        // VCardManager vCardManager = VCardManager(_connection);
        // vCardManager.getSelfVCard().then((vCard) {
        //   Utils.print(print: 'VCard Your Info bDay: ${vCard.bDay}');
        //   Utils.print(print: 'VCard Your Info emailHome: ${vCard.emailHome}');
        //   Utils.print(print: 'VCard Your Info emailWork: ${vCard.emailWork}');
        //   Utils.print(print: 'VCard Your Info familyName: ${vCard.familyName}');
        //   Utils.print(print: 'VCard Your Info fullName: ${vCard.fullName}');
        //   Utils.print(print: 'VCard Your Info givenName: ${vCard.givenName}');
        // Utils.print(
        // print: 'VCard Your Info imageHeight: ${vCard.image.height}');
        //   Utils.print(print: 'VCard Your Info imageType: ${vCard.imageType}');
        //   Utils.print(print: 'VCard Your Info jabberId: ${vCard.jabberId}');
        //   Utils.print(
        //       print:
        //           'VCard Your Info organisationName: ${vCard.organisationName}');
        //   Utils.print(
        //       print:
        //           'VCard Your Info organizationUnit: ${vCard.organizationUnit}');
        //   Utils.print(print: 'VCard Your Info phones: ${vCard.phones}');
        //   Utils.print(print: 'VCard Your Info prefixName: ${vCard.prefixName}');
        //   Utils.print(print: 'VCard Your Info role: ${vCard.role}');
        //   Utils.print(print: 'VCard Your Info title: ${vCard.title}');
        //   Utils.print(print: 'VCard Your Info url: ${vCard.url}');
        //   Utils.print(
        //       print:
        //           'VCard Your Info attributes.length: ${vCard.attributes.length}');
        //   Utils.print(
        //       print:
        //           'VCard Your Info children.length: ${vCard.children.length}');
        //   Utils.print(print: 'VCard Your Info name: ${vCard.name}');
        //   Utils.print(print: 'VCard Your Info textValue: ${vCard.textValue}');
        // });

        // sleep(const Duration(seconds: 1));
        // var receiver = 'dev2@chat.nhtpgroup.com';
        // var receiverJid = Jid.fromFullJid(receiver);
        // rosterManager.addRosterItem(Buddy(receiverJid)).then((result) {
        //   Utils.print(print: 'Roster Result: ${result.type}');

        //   if (result.description != null) {
        //     Utils.print(
        //         print: 'Roster Result Description: ${result.description}');
        //   }
        // });
        // sleep(const Duration(seconds: 1));
        // vCardManager.getVCardFor(receiverJid).then((vCard) {
        //   Utils.print(print: 'Receiver Info: ${vCard.buildXmlString()}');
        //   if (vCard.image != null) {
        //     Utils.print(print: 'Receiver Info: ${vCard.image.height}');
        //     // var file = File('test456789.jpg')
        //     //   ..writeAsBytesSync(image.encodeJpg(vCard.image));
        //     // Log.d(TAG, 'IMAGE SAVED TO: ${file.path}');
        //   }
        // });

      }
    });
  }

  @override
  String get restorationId => RouteName.mainScreen;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_loading, restorationId);
  }

  Widget accountStatusWidget(Jid accountJid) {
    if (accountJid == _presenceManager.selfPresence.jid) {
      switch (_presenceManager.selfPresence.showElement) {
        case PresenceShowElement.CHAT:
          return Icon(
            Icons.circle,
            size: 18,
            color: Colors.green,
          );
        case PresenceShowElement.AWAY:
          return Icon(
            Icons.circle,
            size: 18,
            color: Colors.amber,
          );
        case PresenceShowElement.DND:
          return Icon(
            Icons.circle,
            size: 18,
            color: Colors.red,
          );
        case PresenceShowElement.XA:
          return Icon(
            Icons.circle,
            size: 18,
            color: Colors.grey,
          );
        default:
          return Icon(
            Icons.circle,
            size: 18,
            color: Colors.grey,
          );
      }
    } else {
      // _presenceManager.askDirectPresence(accountJid);
      return StreamBuilder<PresenceData>(
        stream: _presenceManager.presenceStream.firstWhere((presenceData) {
          print(presenceData.jid.userAtDomain);
          print(accountJid.fullJid);
          return presenceData.jid.userAtDomain == accountJid.userAtDomain;
        }).asStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            switch (snapshot.data!.showElement) {
              case PresenceShowElement.CHAT:
                return Icon(
                  Icons.circle,
                  size: 18,
                  color: Colors.green,
                );
              case PresenceShowElement.AWAY:
                return Icon(
                  Icons.circle,
                  size: 18,
                  color: Colors.amber,
                );
              case PresenceShowElement.DND:
                return Icon(
                  Icons.circle,
                  size: 18,
                  color: Colors.red,
                );
              case PresenceShowElement.XA:
                return Icon(
                  Icons.circle,
                  size: 18,
                  color: Colors.grey,
                );
              default:
                return Icon(
                  Icons.circle,
                  size: 18,
                  color: Colors.grey,
                );
            }
          } else {
            return SizedBox();
          }
        },
      );
    }
  }
}
