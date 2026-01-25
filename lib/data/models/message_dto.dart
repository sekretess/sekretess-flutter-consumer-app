import 'package:json_annotation/json_annotation.dart';

part 'message_dto.g.dart';

@JsonSerializable()
class MessageDto {
  @JsonKey(name: 'consumerName')
  final String? consumerName;

  final String text;

  @JsonKey(name: 'businessName')
  final String sender;

  final String type;

  @JsonKey(name: 'messageId')
  final String messageId;

  MessageDto({
    this.consumerName,
    required this.text,
    required this.sender,
    required this.type,
    required this.messageId,
  });

  factory MessageDto.fromJson(Map<String, dynamic> json) =>
      _$MessageDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MessageDtoToJson(this);
}
