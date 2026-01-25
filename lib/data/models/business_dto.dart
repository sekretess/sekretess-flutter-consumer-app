import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'business_dto.g.dart';

enum ItemType {
  @JsonValue('ITEM')
  item,
  @JsonValue('HEADER')
  header,
}

@JsonSerializable()
class BusinessDto extends Equatable {
  @JsonKey(name: 'displayName')
  final String displayName;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'email')
  final String email;

  @JsonKey(name: 'icon')
  final String? icon;

  final bool subscribed;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final ItemType? itemType;

  const BusinessDto({
    required this.displayName,
    required this.name,
    required this.email,
    this.icon,
    this.subscribed = false,
    this.itemType,
  });

  BusinessDto copyWith({
    String? displayName,
    String? name,
    String? email,
    String? icon,
    bool? subscribed,
    ItemType? itemType,
  }) {
    return BusinessDto(
      displayName: displayName ?? this.displayName,
      name: name ?? this.name,
      email: email ?? this.email,
      icon: icon ?? this.icon,
      subscribed: subscribed ?? this.subscribed,
      itemType: itemType ?? this.itemType,
    );
  }
  
  // Helper to check if this is a header item
  bool get isHeader => itemType == ItemType.header;

  factory BusinessDto.fromJson(Map<String, dynamic> json) =>
      _$BusinessDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BusinessDtoToJson(this);

  @override
  List<Object?> get props => [name, email, subscribed];
}
