// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) {
  return Message(
    json['message'] as String,
    json['author'] as String,
    json['chat_id'] as int,
  );
}

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'message': instance.message,
      'author': instance.author,
      'chat_id': instance.chatId,
    };

SendMessage _$SendMessageFromJson(Map<String, dynamic> json) {
  return SendMessage(
    json['message'] as String,
    json['chat_id'] as int,
  );
}

Map<String, dynamic> _$SendMessageToJson(SendMessage instance) =>
    <String, dynamic>{
      'message': instance.message,
      'chat_id': instance.chatId,
    };
