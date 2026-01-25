import 'package:json_annotation/json_annotation.dart';
import 'business_dto.dart';

part 'message_record_dto.g.dart';

@JsonSerializable()
class MessageRecordDto {
  final int? messageId;
  final String sender;
  final String? message;
  final int messageDate;
  final String? dateText;
  final ItemType itemType;

  MessageRecordDto({
    this.messageId,
    required this.sender,
    this.message,
    required this.messageDate,
    this.dateText,
    required this.itemType,
  });

  factory MessageRecordDto.fromJson(Map<String, dynamic> json) =>
      _$MessageRecordDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MessageRecordDtoToJson(this);
}
