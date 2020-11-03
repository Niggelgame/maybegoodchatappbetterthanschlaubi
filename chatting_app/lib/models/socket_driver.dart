import 'dart:async';
import 'dart:convert';

import 'package:chatting_app/models/models.dart';
import 'package:chatting_app/views/chat_view.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SocketDriver extends ChangeNotifier {
  final String username;
  final String password;
  final BuildContext context;
  final GlobalKey<NavigatorState> navigationKey;

  List<Chat> chats;

  WebSocketChannel _channel;

  Uri uri;

  Chat currentlySelectedChat;

  @override
  void dispose() {
    _channel.sink.close(1001);

    super.dispose();
  }

  SocketDriver(this.username, this.password, this.context, this.navigationKey) {
    var attributes = Map<String, dynamic>();
    attributes["username"] = username;
    attributes["password"] = password;
    uri = Uri(
        scheme: "ws",
        host: "192.168.19.66",
        port: 8081,
        queryParameters: attributes);
    _connect();

    _channel.stream.listen(_listen, onDone: _onDone, onError: _onError);
  }

  void _onError(e) {
    print("Websocket listen error: $e");
  }

  void _onDone() {
    print("Done");
  }

  void _listen(packet) {
    _processPacket(packet);
    return;
  }

  _processPacket(packet) {
    var json = jsonDecode(packet);

    var code = json['op'];
    if (code == OPCodes.messageReceive) {
      // Handle Message
      _handleMessage(json);
    } else if (code == OPCodes.chatsReceive) {
      //Handle Chats
      print("Handling Receiving Chats");
      _handleChats(json);
    } else if (code == OPCodes.chatReceive) {
      _handleNewChat(json);
    } else {
      throw Exception("Cannot resolve packet");
    }
  }

  _handleMessage(json) {
    Message m = Message.fromJson(json);
    Chat c = chats.firstWhere((element) => element.chatId == m.chatId);
    if (c == null) {
      /*chats.add(Chat(m.author, m.chatId));
      _handleMessage(json);*/
      return;
    }
    c.addMessage(m);
    if (c.chatId != currentlySelectedChat.chatId) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Message ${m.message} by ${m.author} in chat ${c.chatName}'),
          action: SnackBarAction(
            label: 'Go there',
            onPressed: () {
              selectChat(c);
              navigationKey.currentState.push(
                MaterialPageRoute(
                  builder: (_) => ChatView(c: c),
                ),
              );
            },
          ),
        ),
      );
    }
    notifyListeners();
  }

  _handleChats(json) {
    Chats c = Chats.fromJson(json);
    chats = c.chats;
    notifyListeners();
  }

  _handleNewChat(json) {
    Chat c = Chat.fromJson(json);
    chats.add(c);
    notifyListeners();
  }

  void _connect() {
    _channel = WebSocketChannel.connect(uri);
  }

  sendMessage(String m, int chatId) {
    SendMessage message = SendMessage(m, chatId);

    var p = _turnMessageIntoPacket(message);

    var json = jsonEncode(p);

    _channel.sink.add(json);
  }

  createChat(String name) {
    CreateChat chat = CreateChat(name);

    var p = _turnChatIntoPacket(chat);

    var json = jsonEncode(p);

    _channel.sink.add(json);
  }

  selectChat(Chat c) {
    currentlySelectedChat = c;
  }

  dynamic _turnMessageIntoPacket(SendMessage m) {
    return {'op': OPCodes.messageSend, 'message': m};
  }

  dynamic _turnChatIntoPacket(CreateChat c) {
    return {'op': OPCodes.createdChat, 'message': c};
  }
}

class OPCodes {
  static const messageReceive = "receive_message";
  static const chatsReceive = "receive_chats";
  static const chatReceive = "receive_chat";
  static const messageSend = "send_message";
  static const createdChat = "created_chat";
}
