// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'biometric_capability.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BiometricCapability _$BiometricCapabilityFromJson(Map<String, dynamic> json) =>
    _BiometricCapability(
      isAvailable: json['isAvailable'] as bool? ?? false,
      isDeviceSupported: json['isDeviceSupported'] as bool? ?? false,
      availableTypes: (json['availableTypes'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$BiometricTypeEnumMap, e))
              .toList() ??
          const [],
      canCheckBiometrics: json['canCheckBiometrics'] as bool? ?? false,
    );

Map<String, dynamic> _$BiometricCapabilityToJson(
        _BiometricCapability instance) =>
    <String, dynamic>{
      'isAvailable': instance.isAvailable,
      'isDeviceSupported': instance.isDeviceSupported,
      'availableTypes': instance.availableTypes
          .map((e) => _$BiometricTypeEnumMap[e]!)
          .toList(),
      'canCheckBiometrics': instance.canCheckBiometrics,
    };

const _$BiometricTypeEnumMap = {
  BiometricType.face: 'face',
  BiometricType.fingerprint: 'fingerprint',
  BiometricType.iris: 'iris',
  BiometricType.strong: 'strong',
  BiometricType.weak: 'weak',
};
