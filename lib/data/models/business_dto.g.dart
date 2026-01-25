// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BusinessDto _$BusinessDtoFromJson(Map<String, dynamic> json) => BusinessDto(
      displayName: json['displayName'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      icon: json['icon'] as String?,
      subscribed: json['subscribed'] as bool? ?? false,
    );

Map<String, dynamic> _$BusinessDtoToJson(BusinessDto instance) =>
    <String, dynamic>{
      'displayName': instance.displayName,
      'name': instance.name,
      'email': instance.email,
      'icon': instance.icon,
      'subscribed': instance.subscribed,
    };
