import 'package:flutter/material.dart';

class AuthConfig {
  final bool biometricEnabled;
  final bool passwordEnabled;
  final int authTimeoutMinutes;
  final ThemeMode themeMode;
  final String? hashedPassword;
  final int failedAttempts;
  final DateTime? lockoutEndTime;
  final DateTime? lastAuthTime;

  const AuthConfig({
    this.biometricEnabled = false,
    this.passwordEnabled = false,
    this.authTimeoutMinutes = 15,
    this.themeMode = ThemeMode.system,
    this.hashedPassword,
    this.failedAttempts = 0,
    this.lockoutEndTime,
    this.lastAuthTime,
  });

  AuthConfig copyWith({
    bool? biometricEnabled,
    bool? passwordEnabled,
    int? authTimeoutMinutes,
    ThemeMode? themeMode,
    String? hashedPassword,
    int? failedAttempts,
    DateTime? lockoutEndTime,
    DateTime? lastAuthTime,
  }) {
    return AuthConfig(
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      passwordEnabled: passwordEnabled ?? this.passwordEnabled,
      authTimeoutMinutes: authTimeoutMinutes ?? this.authTimeoutMinutes,
      themeMode: themeMode ?? this.themeMode,
      hashedPassword: hashedPassword ?? this.hashedPassword,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      lockoutEndTime: lockoutEndTime ?? this.lockoutEndTime,
      lastAuthTime: lastAuthTime ?? this.lastAuthTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'biometricEnabled': biometricEnabled,
      'passwordEnabled': passwordEnabled,
      'authTimeoutMinutes': authTimeoutMinutes,
      'themeMode': themeMode.index,
      'hashedPassword': hashedPassword,
      'failedAttempts': failedAttempts,
      'lockoutEndTime': lockoutEndTime?.millisecondsSinceEpoch,
      'lastAuthTime': lastAuthTime?.millisecondsSinceEpoch,
    };
  }

  factory AuthConfig.fromJson(Map<String, dynamic> json) {
    return AuthConfig(
      biometricEnabled: json['biometricEnabled'] ?? false,
      passwordEnabled: json['passwordEnabled'] ?? false,
      authTimeoutMinutes: json['authTimeoutMinutes'] ?? 15,
      themeMode: ThemeMode.values[json['themeMode'] ?? 0],
      hashedPassword: json['hashedPassword'],
      failedAttempts: json['failedAttempts'] ?? 0,
      lockoutEndTime: json['lockoutEndTime'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['lockoutEndTime'])
          : null,
      lastAuthTime: json['lastAuthTime'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['lastAuthTime'])
          : null,
    );
  }
}

extension AuthConfigExtension on AuthConfig {
  bool get hasAnyAuthEnabled => biometricEnabled || passwordEnabled;
  
  bool get isLocked {
    if (lockoutEndTime == null) return false;
    return DateTime.now().isBefore(lockoutEndTime!);
  }
  
  Duration? get lockoutRemaining {
    if (!isLocked) return null;
    return lockoutEndTime!.difference(DateTime.now());
  }
  
  bool get isAuthValid {
    if (lastAuthTime == null) return false;
    final validUntil = lastAuthTime!.add(Duration(minutes: authTimeoutMinutes));
    return DateTime.now().isBefore(validUntil);
  }
  
  AuthConfig copyWithNewAuth() {
    return copyWith(
      lastAuthTime: DateTime.now(),
      failedAttempts: 0,
      lockoutEndTime: null,
    );
  }
  
  AuthConfig copyWithFailedAttempt() {
    final newFailedAttempts = failedAttempts + 1;
    DateTime? newLockoutEndTime;
    
    // 3次失败后锁定30秒
    if (newFailedAttempts >= 3) {
      newLockoutEndTime = DateTime.now().add(const Duration(seconds: 30));
    }
    
    return copyWith(
      failedAttempts: newFailedAttempts,
      lockoutEndTime: newLockoutEndTime,
    );
  }
}