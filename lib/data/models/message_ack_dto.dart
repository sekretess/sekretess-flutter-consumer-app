import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'message_ack_dto.g.dart';

@JsonSerializable()
class MessageAckDto {
  @JsonKey(name: 'messageId')
  final String messageId;

  @JsonKey(name: 'status')
  final int status;

  MessageAckDto({
    required this.messageId,
    required this.status,
  });

  factory MessageAckDto.fromJson(Map<String, dynamic> json) =>
      _$MessageAckDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MessageAckDtoToJson(this);

  String jsonString() {
    return jsonEncode(toJson());
  }
}
