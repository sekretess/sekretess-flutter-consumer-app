// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserDto _$UserDtoFromJson(Map<String, dynamic> json) => UserDto(
      username: json['username'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      regId: (json['regId'] as num?)?.toInt(),
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

Map<String, dynamic> _$UserDtoToJson(UserDto instance) => <String, dynamic>{
      'username': instance.username,
      'email': instance.email,
      'password': instance.password,
      'regId': instance.regId,
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
