import 'package:chatting_app/models/models.dart';
import 'package:chatting_app/models/socket_driver.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat.g.dart';

@JsonSerializable()
class Chat with ChangeNotifier {
  List<Message> _messages = [];

  List<Message> get messages => _messages;

  @JsonKey(name: 'chat_name')
  final String chatName;
  @JsonKey(name: 'chat_id')
  final int chatId;

  Chat(this.chatName, this.chatId);

  factory Chat.fromJson(Map<String, dynamic> json) => _$ChatFromJson(json);

  Map<String, dynamic> toJson() => _$ChatToJson(this);

  void sendMessage(SocketDriver d, String message) {
    d.sendMessage(message, chatId);

    print("Sending message $message");
  }

  void addMessage(Message m) {
    _messages.add(m);
    notifyListeners();
  }
}

@JsonSerializable()
class Chats {
  final List<Chat> chats;

  Chats(this.chats);

  factory Chats.fromJson(Map<String, dynamic> json) => _$ChatsFromJson(json);

  Map<String, dynamic> toJson() => _$ChatsToJson(this);
}


@JsonSerializable()
class CreateChat {
  final String name;

  CreateChat(this.name);

  factory CreateChat.fromJson(Map<String, dynamic> json) => _$CreateChatFromJson(json);

  Map<String, dynamic> toJson() => _$CreateChatToJson(this);
}