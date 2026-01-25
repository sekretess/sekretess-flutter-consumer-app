import 'package:json_annotation/json_annotation.dart';

part 'user_dto.g.dart';

@JsonSerializable()
class UserDto {
  @JsonKey(name: 'username')
  final String username;

  @JsonKey(name: 'email')
  final String email;

  @JsonKey(name: 'password')
  final String password;

  @JsonKey(name: 'regId')
  final int? regId;

  @JsonKey(name: 'ik')
  final String? ik;

  @JsonKey(name: 'spk')
  final String? spk;

  @JsonKey(name: 'opk')
  final List<String>? opk;

  @JsonKey(name: 'SPKSignature')
  final String? spkSignature;

  @JsonKey(name: 'spkID')
  final String? spkId;

  @JsonKey(name: 'PQSPK')
  final String? pqspk;

  @JsonKey(name: 'PQSPKID')
  final String? pqspkId;

  @JsonKey(name: 'PQSPKSignature')
  final String? pqspkSignature;

  @JsonKey(name: 'OPQK')
  final List<String>? opqk;

  @JsonKey(name: 'deviceRegistrationToken')
  final String? deviceRegistrationToken;

  UserDto({
    required this.username,
    required this.email,
    required this.password,
    this.regId,
    this.ik,
    this.spk,
    this.opk,
    this.spkSignature,
    this.spkId,
    this.pqspk,
    this.pqspkId,
    this.pqspkSignature,
    this.opqk,
    this.deviceRegistrationToken,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserDtoToJson(this);
}
