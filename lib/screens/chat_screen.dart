import 'package:flutter/material.dart';
import 'package:simple_chat_apk/Components/utils.dart';
import 'package:simple_chat_apk/Components/utils_widget.dart';
import 'package:xmpp_stone/xmpp_stone.dart';

class ChatScreen extends StatefulWidget {
  final XmppAccountSettings xmppAccount;
  final Buddy reciverBuddy;
  final Connection connection;
  const ChatScreen({
    Key? key,
    required this.reciverBuddy,
    required this.xmppAccount,
    required this.connection,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _messageContoller = TextEditingController();
  late RosterManager _rosterManager;
  late MessageHandler _messageHandler;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _messageContoller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.reciverBuddy.jid.local,
              style: theme.textTheme.subtitle1?.copyWith(color: Colors.white),
            ),
            Text(
              widget.reciverBuddy.jid.fullJid,
              style: theme.textTheme.caption?.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Text('Chat Screen'),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Transform.translate(
        offset: Offset(0, -1 * MediaQuery.of(context).viewInsets.bottom),
        child: BottomAppBar(
          child: Row(
            children: [
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Aa',
                      contentPadding: EdgeInsets.fromLTRB(20.0, 2.0, 20.0, 2.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32.0),
                      ),
                    ),
                    textInputAction: TextInputAction.newline,
                    keyboardType: TextInputType.multiline,
                    controller: _messageContoller,
                    maxLines: 4,
                    minLines: 1,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.send),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendClick() {
    if (_messageContoller.text.trim().isNotEmpty) {
      Utils.print(print: 'Message : ${_messageContoller.text}');
      _rosterManager.addRosterItem(widget.reciverBuddy).then((value) {
        print(value.iqStanzaId);
        print(value.type);
        print(value.description);
        return null;
      });
      // .addRosterItem(receiverBuddy)
      // .asStream()
      // .listen((iqStanzaResult) {});
      // .then((result) {
      //   Utils.print(print: 'Roster Add Item Result Type: ${result.type}');
      //   if (result.description != null) {
      //     Utils.print(
      //         print:
      //             'Roster Add Item Result Descripiton: ${result.description}');
      //   }
      // }, onError: (error) {
      //   print("Roster Add Item Error");
      // });
      // sleep(const Duration(seconds: 1));
      _messageHandler.sendMessage(
          widget.reciverBuddy.jid, _messageContoller.text);
      _messageContoller.clear();
    }
  }
}
