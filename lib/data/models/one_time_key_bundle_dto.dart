import 'package:json_annotation/json_annotation.dart';

part 'one_time_key_bundle_dto.g.dart';

@JsonSerializable()
class OneTimeKeyBundleDto {
  @JsonKey(name: 'OPK')
  final List<String> opk;

  @JsonKey(name: 'OPQK')
  final List<String> opqk;

  OneTimeKeyBundleDto({
    required this.opk,
    required this.opqk,
  });

  factory OneTimeKeyBundleDto.fromJson(Map<String, dynamic> json) =>
      _$OneTimeKeyBundleDtoFromJson(json);

  Map<String, dynamic> toJson() => _$OneTimeKeyBundleDtoToJson(this);
}
