import 'package:local_auth/local_auth.dart';
import 'package:mykeyvault/models/models.dart';
import 'package:mykeyvault/services/secure_storage_service.dart';

class AuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final SecureStorageService _secureStorage = SecureStorageService();

  /// 检测设备生物识别能力
  Future<BiometricCapability> checkBiometricCapability() async {
    try {
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      final List<BiometricType> availableTypes = await _localAuth.getAvailableBiometrics();

      return BiometricCapability(
        isAvailable: isAvailable,
        isDeviceSupported: isDeviceSupported,
        availableTypes: availableTypes,
        canCheckBiometrics: isAvailable && isDeviceSupported,
      );
    } catch (e) {
      throw AuthException(AuthError.systemError, '检测生物识别能力失败: $e');
    }
  }

  /// 执行生物识别认证
  Future<bool> authenticateWithBiometric() async {
    try {
      final capability = await checkBiometricCapability();
      
      if (!capability.isUsable) {
        throw AuthException(AuthError.biometricNotAvailable, '生物识别不可用');
      }

      if (capability.availableTypes.isEmpty) {
        throw AuthException(AuthError.biometricNotEnrolled, '请先设置生物识别');
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: '请验证您的身份以访问应用',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      return didAuthenticate;
    } on AuthException {
      rethrow;
    } catch (e) {
      // 处理特定的local_auth异常
      final errorMessage = e.toString();
      if (errorMessage.contains('locked')) {
        throw AuthException(AuthError.biometricLockout, '生物识别已被锁定');
      } else if (errorMessage.contains('not available')) {
        throw AuthException(AuthError.biometricNotAvailable, '生物识别不可用');
      } else if (errorMessage.contains('not enrolled')) {
        throw AuthException(AuthError.biometricNotEnrolled, '请先设置生物识别');
      } else {
        throw AuthException(AuthError.systemError, '生物识别认证失败: $e');
      }
    }
  }

  /// 设置密码
  Future<void> setPassword(String password) async {
    if (password.length != 6 || !RegExp(r'^\d{6}$').hasMatch(password)) {
      throw AuthException(AuthError.systemError, '密码必须是6位数字');
    }

    try {
      await _secureStorage.setPassword(password);
    } catch (e) {
      throw AuthException(AuthError.systemError, '设置密码失败: $e');
    }
  }

  /// 验证密码
  Future<bool> verifyPassword(String password) async {
    try {
      return await _secureStorage.verifyPassword(password);
    } catch (e) {
      throw AuthException(AuthError.systemError, '验证密码失败: $e');
    }
  }

  /// 检查是否已设置密码
  Future<bool> hasPassword() async {
    try {
      return await _secureStorage.hasPassword();
    } catch (e) {
      return false;
    }
  }

  /// 删除密码
  Future<void> removePassword() async {
    try {
      await _secureStorage.removePassword();
    } catch (e) {
      throw AuthException(AuthError.systemError, '删除密码失败: $e');
    }
  }

  /// 保存认证配置
  Future<void> saveAuthConfig(AuthConfig config) async {
    try {
      await _secureStorage.saveAuthConfig(config);
    } catch (e) {
      throw AuthException(AuthError.systemError, '保存配置失败: $e');
    }
  }

  /// 加载认证配置
  Future<AuthConfig> loadAuthConfig() async {
    try {
      return await _secureStorage.loadAuthConfig();
    } catch (e) {
      throw AuthException(AuthError.systemError, '加载配置失败: $e');
    }
  }

  /// 处理认证失败（增加失败次数，可能触发锁定）
  Future<AuthConfig> handleAuthFailure(AuthConfig currentConfig) async {
    final updatedConfig = currentConfig.copyWithFailedAttempt();
    await saveAuthConfig(updatedConfig);
    return updatedConfig;
  }

  /// 处理认证成功（重置失败次数，更新认证时间）
  Future<AuthConfig> handleAuthSuccess(AuthConfig currentConfig) async {
    final updatedConfig = currentConfig.copyWithNewAuth();
    await saveAuthConfig(updatedConfig);
    return updatedConfig;
  }

  /// 检查是否被锁定
  bool isLocked(AuthConfig config) {
    return config.isLocked;
  }

  /// 获取锁定剩余时间
  Duration? getLockoutRemaining(AuthConfig config) {
    return config.lockoutRemaining;
  }

  /// 检查认证是否仍然有效
  bool isAuthValid(AuthConfig config) {
    return config.isAuthValid;
  }

  /// 清除所有认证数据
  Future<void> clearAllAuthData() async {
    try {
      await _secureStorage.clearAll();
    } catch (e) {
      throw AuthException(AuthError.systemError, '清除认证数据失败: $e');
    }
  }

  /// 获取推荐的认证方法
  Future<AuthMethod> getRecommendedAuthMethod(AuthConfig config) async {
    if (config.isLocked) {
      return AuthMethod.none;
    }

    if (config.biometricEnabled) {
      final capability = await checkBiometricCapability();
      if (capability.isUsable) {
        return AuthMethod.biometric;
      }
    }

    if (config.passwordEnabled) {
      return AuthMethod.password;
    }

    return AuthMethod.none;
  }
}