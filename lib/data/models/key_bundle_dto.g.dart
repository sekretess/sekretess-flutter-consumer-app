// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'key_bundle_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KeyBundleDto _$KeyBundleDtoFromJson(Map<String, dynamic> json) => KeyBundleDto(
      regId: (json['RegID'] as num?)?.toInt(),
      ik: json['ik'] as String?,
      spk: json['spk'] as String?,
      opk: (json['opk'] as List<dynamic>?)?.map((e) => e as String).toList(),
      spkSignature: json['SPKSignature'] as String?,
      spkId: json['spkID'] as String?,
      pqspk: json['PQSPK'] as String?,
      pqspkId: json['PQSPKID'] as String?,
      pqspkSignature: json['PQSPKSignature'] as String?,
      opqk: (json['OPQK'] as List<dynamic>?)?.map((e) => e as String).toList(),
      deviceRegistrationToken: json['deviceRegistrationToken'] as String?,
    );

Map<String, dynamic> _$KeyBundleDtoToJson(KeyBundleDto instance) =>
    <String, dynamic>{
      'RegID': instance.regId,
      'ik': instance.ik,
      'spk': instance.spk,
      'opk': instance.opk,
      'SPKSignature': instance.spkSignature,
      'spkID': instance.spkId,
      'PQSPK': instance.pqspk,
      'PQSPKID': instance.pqspkId,
      'PQSPKSignature': instance.pqspkSignature,
      'OPQK': instance.opqk,
      'deviceRegistrationToken': instance.deviceRegistrationToken,
    };
