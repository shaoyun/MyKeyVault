import 'package:local_auth/local_auth.dart';

class BiometricCapability {
  final bool isAvailable;
  final bool isDeviceSupported;
  final List<BiometricType> availableTypes;
  final bool canCheckBiometrics;

  const BiometricCapability({
    this.isAvailable = false,
    this.isDeviceSupported = false,
    this.availableTypes = const [],
    this.canCheckBiometrics = false,
  });

  BiometricCapability copyWith({
    bool? isAvailable,
    bool? isDeviceSupported,
    List<BiometricType>? availableTypes,
    bool? canCheckBiometrics,
  }) {
    return BiometricCapability(
      isAvailable: isAvailable ?? this.isAvailable,
      isDeviceSupported: isDeviceSupported ?? this.isDeviceSupported,
      availableTypes: availableTypes ?? this.availableTypes,
      canCheckBiometrics: canCheckBiometrics ?? this.canCheckBiometrics,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isAvailable': isAvailable,
      'isDeviceSupported': isDeviceSupported,
      'availableTypes': availableTypes.map((e) => e.index).toList(),
      'canCheckBiometrics': canCheckBiometrics,
    };
  }

  factory BiometricCapability.fromJson(Map<String, dynamic> json) {
    return BiometricCapability(
      isAvailable: json['isAvailable'] ?? false,
      isDeviceSupported: json['isDeviceSupported'] ?? false,
      availableTypes: (json['availableTypes'] as List<dynamic>?)
          ?.map((e) => BiometricType.values[e as int])
          .toList() ?? [],
      canCheckBiometrics: json['canCheckBiometrics'] ?? false,
    );
  }
}

extension BiometricCapabilityExtension on BiometricCapability {
  bool get hasFingerprint => availableTypes.contains(BiometricType.fingerprint);
  bool get hasFace => availableTypes.contains(BiometricType.face);
  bool get hasIris => availableTypes.contains(BiometricType.iris);
  
  String get primaryBiometricName {
    if (hasFingerprint) return '指纹';
    if (hasFace) return '面部识别';
    if (hasIris) return '虹膜识别';
    return '生物识别';
  }
  
  bool get isUsable => isAvailable && isDeviceSupported && canCheckBiometrics;
}