// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'one_time_key_bundle_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OneTimeKeyBundleDto _$OneTimeKeyBundleDtoFromJson(Map<String, dynamic> json) =>
    OneTimeKeyBundleDto(
      opk: (json['OPK'] as List<dynamic>).map((e) => e as String).toList(),
      opqk: (json['OPQK'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$OneTimeKeyBundleDtoToJson(
        OneTimeKeyBundleDto instance) =>
    <String, dynamic>{
      'OPK': instance.opk,
      'OPQK': instance.opqk,
    };
