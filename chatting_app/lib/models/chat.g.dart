// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Chat _$ChatFromJson(Map<String, dynamic> json) {
  return Chat(
    json['chat_name'] as String,
    json['chat_id'] as int,
  );
}

Map<String, dynamic> _$ChatToJson(Chat instance) => <String, dynamic>{
      'chat_name': instance.chatName,
      'chat_id': instance.chatId,
    };

Chats _$ChatsFromJson(Map<String, dynamic> json) {
  return Chats(
    (json['chats'] as List)
        ?.map(
            (e) => e == null ? null : Chat.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$ChatsToJson(Chats instance) => <String, dynamic>{
      'chats': instance.chats,
    };

CreateChat _$CreateChatFromJson(Map<String, dynamic> json) {
  return CreateChat(
    json['name'] as String,
  );
}

Map<String, dynamic> _$CreateChatToJson(CreateChat instance) =>
    <String, dynamic>{
      'name': instance.name,
    };
