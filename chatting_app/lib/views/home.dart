import 'package:chatting_app/models/chat.dart';
import 'package:chatting_app/models/socket_driver.dart';
import 'package:chatting_app/views/chat_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';

class Home extends StatefulWidget {
  final String username;
  final String password;
  final String host;
  final int port;

  const Home({Key key, @required this.username, @required this.password, @required this.host, @required this.port})
      : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<NavigatorState> key = GlobalKey();
  BuildContext providerContext;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          return !(await key.currentState.maybePop());
        },
        child: Builder(builder: (context) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => SocketDriver(
                    widget.host, widget.port, widget.username, widget.password, context, key),
                lazy: false,
                builder: (context, widget) {
                  providerContext = context;
                  return Scaffold(
                    body: Navigator(
                      initialRoute: "/home",
                      onGenerateRoute: (routeSettings) {
                        if (routeSettings.name == "/home") {
                          return MaterialPageRoute(builder: (_) => _Home());
                        } else {
                          return MaterialPageRoute(builder: (_) => Container());
                        }
                      },
                      key: key,
                    ),
                  );
                },
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (context.watch<SocketDriver>().chats == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        leading: Navigator.of(context, rootNavigator: true).canPop()
            ? GestureDetector(
                child: Icon(Icons.arrow_back_ios),
                onTap: () {
                  Navigator.of(context, rootNavigator: true).maybePop();
                },
              )
            : Container(),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        tooltip: "Create new Chat",
        onPressed: () async {
          var name = await showTextInputDialog(
            context: context,
            textFields: [
              DialogTextField(
                hintText: 'Channel name',
                validator: (text) {
                  if (text.isEmpty) {
                    return "Text may not be empty";
                  } else {
                    return null;
                  }
                },
              ),
            ],
          );
          if(name != null) {
            context.read<SocketDriver>().createChat(name.first);
          }
        },
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return _ChatPreview(
            chat: context.watch<SocketDriver>().chats[index],
          );
        },
        itemCount: context.watch<SocketDriver>().chats.length,
      ),
    );
  }
}

class _ChatPreview extends StatelessWidget {
  final Chat chat;

  const _ChatPreview({Key key, this.chat}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    print(chat.chatName);
    return GestureDetector(
      onTap: () {
        if(chat.isJoined) {
          context.read<SocketDriver>().selectChat(chat);
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => ChatView(c: chat)));
        }
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chat.chatName ?? '',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      chat.messages != null && chat.messages.length > 0 ? '${chat.messages.last.author}: ${chat.messages.last.message}' : 'Join',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                    ),
                  ],
                ),
              ),
              chat.isJoined
                  ? Container()
                  : RaisedButton(
                      onPressed: () =>
                          context.read<SocketDriver>().joinChat(chat),
                      child: Text('Join'),
                      color: Colors.green,
                    )
            ],
          ),
        ),
      ),
    );
  }
}
