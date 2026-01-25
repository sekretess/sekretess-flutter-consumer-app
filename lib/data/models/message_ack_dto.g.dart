// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_ack_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageAckDto _$MessageAckDtoFromJson(Map<String, dynamic> json) =>
    MessageAckDto(
      messageId: json['messageId'] as String,
      status: (json['status'] as num).toInt(),
    );

Map<String, dynamic> _$MessageAckDtoToJson(MessageAckDto instance) =>
    <String, dynamic>{
      'messageId': instance.messageId,
      'status': instance.status,
    };
