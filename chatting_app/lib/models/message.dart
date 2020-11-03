import 'package:chatting_app/models/socket_driver.dart';
import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

@JsonSerializable()
class Message {
  final String message;

  final String author;

  @JsonKey(name: 'chat_id')
  final int chatId;

  Message(this.message, this.author, this.chatId);

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);
}

@JsonSerializable()
class SendMessage {
  final String message;
  @JsonKey(name: 'chat_id')
  final int chatId;

  SendMessage(this.message, this.chatId);

  factory SendMessage.fromJson(Map<String, dynamic> json) => _$SendMessageFromJson(json);

  Map<String, dynamic> toJson() => _$SendMessageToJson(this);
}