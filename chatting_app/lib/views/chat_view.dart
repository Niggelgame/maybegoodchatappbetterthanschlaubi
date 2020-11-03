import 'package:chatting_app/models/models.dart';
import 'package:chatting_app/models/socket_driver.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatView extends StatefulWidget {
  final Chat c;

  const ChatView({Key key, @required this.c}) : super(key: key);

  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.c.chatName),
      ),
      body: Builder(
        builder: (context) {
          return Column(
            children: [
              Expanded(
                child: ListView(
                  children: context
                      .watch<SocketDriver>()
                      .chats
                      .firstWhere(
                          (element) => element.chatId == widget.c.chatId)
                      .messages
                      .map((e) => _MessageBox(
                            message: e,
                          ))
                      .toList(),
                  reverse: false,
                ),
              ),
              _MessageSender(c: widget.c),
            ],
          );
        },
      ),
    );
  }
}

class _MessageBox extends StatelessWidget {
  final Message message;

  const _MessageBox({Key key, @required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.author ?? '',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Text(
              message.message ?? '',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageSender extends StatefulWidget {
  final Chat c;

  const _MessageSender({Key key, @required this.c}) : super(key: key);

  @override
  _MessageSenderState createState() => _MessageSenderState();
}

class _MessageSenderState extends State<_MessageSender> {
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onSubmitted: (_) {
                send(context);
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.send_outlined),
            onPressed: () {
              send(context);
            },
          ),
        ],
      ),
    );
  }

  void send(BuildContext context) {
    if (_controller.text.isNotEmpty) {
      context
          .read<SocketDriver>()
          .chats
          .firstWhere((element) => element.chatId == widget.c.chatId)
          .sendMessage(context.read<SocketDriver>(), _controller.text);
      _controller.clear();
    }
  }
}
