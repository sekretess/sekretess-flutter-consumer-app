// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_brief_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageBriefDto _$MessageBriefDtoFromJson(Map<String, dynamic> json) =>
    MessageBriefDto(
      sender: json['sender'] as String,
      messageBody: json['messageBody'] as String,
      timestamp: (json['timestamp'] as num?)?.toInt(),
    );

Map<String, dynamic> _$MessageBriefDtoToJson(MessageBriefDto instance) =>
    <String, dynamic>{
      'sender': instance.sender,
      'messageBody': instance.messageBody,
      'timestamp': instance.timestamp,
    };
