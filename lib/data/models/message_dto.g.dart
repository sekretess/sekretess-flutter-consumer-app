// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageDto _$MessageDtoFromJson(Map<String, dynamic> json) => MessageDto(
      consumerName: json['consumerName'] as String?,
      text: json['text'] as String,
      sender: json['businessName'] as String,
      type: json['type'] as String,
      messageId: json['messageId'] as String,
    );

Map<String, dynamic> _$MessageDtoToJson(MessageDto instance) =>
    <String, dynamic>{
      'consumerName': instance.consumerName,
      'text': instance.text,
      'businessName': instance.sender,
      'type': instance.type,
      'messageId': instance.messageId,
    };
