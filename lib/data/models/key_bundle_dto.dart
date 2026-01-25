import 'package:json_annotation/json_annotation.dart';

part 'key_bundle_dto.g.dart';

@JsonSerializable()
class KeyBundleDto {
  @JsonKey(name: 'RegID')
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

  KeyBundleDto({
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

  factory KeyBundleDto.fromJson(Map<String, dynamic> json) =>
      _$KeyBundleDtoFromJson(json);

  Map<String, dynamic> toJson() => _$KeyBundleDtoToJson(this);
}
