enum AuthError {
  biometricNotAvailable,
  biometricNotEnrolled,
  biometricLockout,
  passwordIncorrect,
  tooManyAttempts,
  systemError,
}

class AuthException implements Exception {
  final AuthError error;
  final String message;
  
  const AuthException(this.error, this.message);
  
  @override
  String toString() => 'AuthException: $message';
}

extension AuthErrorExtension on AuthError {
  String get message {
    switch (this) {
      case AuthError.biometricNotAvailable:
        return '设备不支持生物识别认证';
      case AuthError.biometricNotEnrolled:
        return '请先在系统设置中设置生物识别';
      case AuthError.biometricLockout:
        return '生物识别已被锁定，请稍后再试';
      case AuthError.passwordIncorrect:
        return '密码错误';
      case AuthError.tooManyAttempts:
        return '尝试次数过多，请稍后再试';
      case AuthError.systemError:
        return '系统错误，请重试';
    }
  }
  
  AuthException get exception => AuthException(this, message);
}