// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'totp_account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TotpAccount _$TotpAccountFromJson(Map<String, dynamic> json) => _TotpAccount(
      id: json['id'] as String,
      issuer: json['issuer'] as String,
      name: json['name'] as String,
      secret: json['secret'] as String,
      colorType: json['colorType'] as String? ?? 'default',
    );

Map<String, dynamic> _$TotpAccountToJson(_TotpAccount instance) =>
    <String, dynamic>{
      'id': instance.id,
      'issuer': instance.issuer,
      'name': instance.name,
      'secret': instance.secret,
      'colorType': instance.colorType,
    };
