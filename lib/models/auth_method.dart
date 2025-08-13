enum AuthMethod {
  biometric,
  password,
  none,
}

extension AuthMethodExtension on AuthMethod {
  String get displayName {
    switch (this) {
      case AuthMethod.biometric:
        return '生物识别';
      case AuthMethod.password:
        return '密码';
      case AuthMethod.none:
        return '无';
    }
  }
  
  bool get isSecure {
    return this != AuthMethod.none;
  }
}