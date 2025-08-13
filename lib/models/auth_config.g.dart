// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthConfig _$AuthConfigFromJson(Map<String, dynamic> json) => _AuthConfig(
      biometricEnabled: json['biometricEnabled'] as bool? ?? false,
      passwordEnabled: json['passwordEnabled'] as bool? ?? false,
      authTimeoutMinutes: (json['authTimeoutMinutes'] as num?)?.toInt() ?? 15,
      themeMode: $enumDecodeNullable(_$ThemeModeEnumMap, json['themeMode']) ??
          ThemeMode.system,
      hashedPassword: json['hashedPassword'] as String?,
      failedAttempts: (json['failedAttempts'] as num?)?.toInt() ?? 0,
      lockoutEndTime: json['lockoutEndTime'] == null
          ? null
          : DateTime.parse(json['lockoutEndTime'] as String),
      lastAuthTime: json['lastAuthTime'] == null
          ? null
          : DateTime.parse(json['lastAuthTime'] as String),
    );

Map<String, dynamic> _$AuthConfigToJson(_AuthConfig instance) =>
    <String, dynamic>{
      'biometricEnabled': instance.biometricEnabled,
      'passwordEnabled': instance.passwordEnabled,
      'authTimeoutMinutes': instance.authTimeoutMinutes,
      'themeMode': _$ThemeModeEnumMap[instance.themeMode]!,
      'hashedPassword': instance.hashedPassword,
      'failedAttempts': instance.failedAttempts,
      'lockoutEndTime': instance.lockoutEndTime?.toIso8601String(),
      'lastAuthTime': instance.lastAuthTime?.toIso8601String(),
    };

const _$ThemeModeEnumMap = {
  ThemeMode.system: 'system',
  ThemeMode.light: 'light',
  ThemeMode.dark: 'dark',
};
