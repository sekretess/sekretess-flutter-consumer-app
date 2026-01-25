import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'message_brief_dto.g.dart';

@JsonSerializable()
class MessageBriefDto extends Equatable {
  final String sender;
  final String messageBody;
  final int? timestamp;

  const MessageBriefDto({
    required this.sender,
    required this.messageBody,
    this.timestamp,
  });

  factory MessageBriefDto.fromJson(Map<String, dynamic> json) =>
      _$MessageBriefDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MessageBriefDtoToJson(this);

  String get messageText => messageBody;

  @override
  List<Object?> get props => [sender, messageBody];
}
