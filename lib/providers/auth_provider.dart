import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mykeyvault/models/models.dart';
import 'package:mykeyvault/services/auth_service.dart';
import 'package:mykeyvault/utils/performance_utils.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  // 认证状态
  bool _isAuthenticated = false;
  AuthMethod _currentAuthMethod = AuthMethod.none;
  AuthConfig _config = const AuthConfig();
  BiometricCapability _biometricCapability = const BiometricCapability();
  
  // 会话管理
  Timer? _sessionTimer;
  Timer? _lockoutTimer;
  
  // 错误状态
  AuthError? _lastError;
  String? _errorMessage;
  
  // 性能优化
  bool _isInitialized = false;
  bool _isInitializing = false;
  DateTime? _lastBiometricCheck;
  static const Duration _biometricCheckCacheDuration = Duration(minutes: 5);

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  AuthMethod get currentAuthMethod => _currentAuthMethod;
  AuthConfig get config => _config;
  BiometricCapability get biometricCapability => _biometricCapability;
  AuthError? get lastError => _lastError;
  String? get errorMessage => _errorMessage;
  
  bool get hasAnyAuthEnabled => _config.hasAnyAuthEnabled;
  bool get isLocked => _config.isLocked;
  Duration? get lockoutRemaining => _config.lockoutRemaining;
  bool get canUseBiometric => _config.biometricEnabled && _biometricCapability.isUsable;
  bool get canUsePassword => _config.passwordEnabled;

  /// 初始化认证提供者
  Future<void> initialize() async {
    if (_isInitialized || _isInitializing) return;
    
    _isInitializing = true;
    try {
      await PerformanceUtils.measureAsync('auth_provider_init', () async {
        await _loadConfig();
        await _checkBiometricCapabilityIfNeeded();
        _setupAppLifecycleListener();
        
        // 检查是否有有效的认证会话
        if (_config.isAuthValid) {
          _isAuthenticated = true;
          _startSessionTimer();
        }
      });
      
      _isInitialized = true;
      
      notifyListeners();
    } catch (e) {
      _setError(AuthError.systemError, '初始化失败: $e');
    }
  }

  /// 加载认证配置
  Future<void> _loadConfig() async {
    try {
      _config = await _authService.loadAuthConfig();
    } catch (e) {
      if (kDebugMode) {
        print('加载配置失败，使用默认配置: $e');
      }
      _config = const AuthConfig();
    }
  }

  /// 检查生物识别能力
  Future<void> _checkBiometricCapability() async {
    try {
      _biometricCapability = await _authService.checkBiometricCapability();
      _lastBiometricCheck = DateTime.now();
    } catch (e) {
      if (kDebugMode) {
        print('检查生物识别能力失败: $e');
      }
      _biometricCapability = const BiometricCapability();
    }
  }
  
  /// 如果需要则检查生物识别能力（带缓存）
  Future<void> _checkBiometricCapabilityIfNeeded() async {
    final now = DateTime.now();
    if (_lastBiometricCheck == null || 
        now.difference(_lastBiometricCheck!) > _biometricCheckCacheDuration) {
      await _checkBiometricCapability();
    }
  }

  /// 使用生物识别认证
  Future<bool> authenticateWithBiometric() async {
    return await PerformanceUtils.measureAsync('biometric_auth', () async {
      if (!canUseBiometric) {
        _setError(AuthError.biometricNotAvailable, '生物识别不可用');
        return false;
      }

      if (isLocked) {
        _setError(AuthError.tooManyAttempts, '账户已被锁定');
        return false;
      }

      try {
        _clearError();
        final success = await _authService.authenticateWithBiometric();
        
        if (success) {
          await _handleAuthSuccess(AuthMethod.biometric);
          return true;
        } else {
          await _handleAuthFailure();
          return false;
        }
      } on AuthException catch (e) {
        _setError(e.error, e.message);
        await _handleAuthFailure();
        return false;
      } catch (e) {
        _setError(AuthError.systemError, '生物识别认证失败: $e');
        await _handleAuthFailure();
        return false;
      }
    });
  }

  /// 使用密码认证
  Future<bool> authenticateWithPassword(String password) async {
    if (!canUsePassword) {
      _setError(AuthError.systemError, '密码认证不可用');
      return false;
    }

    if (isLocked) {
      _setError(AuthError.tooManyAttempts, '账户已被锁定');
      return false;
    }

    try {
      _clearError();
      final success = await _authService.verifyPassword(password);
      
      if (success) {
        await _handleAuthSuccess(AuthMethod.password);
        return true;
      } else {
        _setError(AuthError.passwordIncorrect, '密码错误');
        await _handleAuthFailure();
        return false;
      }
    } catch (e) {
      _setError(AuthError.systemError, '密码认证失败: $e');
      await _handleAuthFailure();
      return false;
    }
  }

  /// 处理认证成功
  Future<void> _handleAuthSuccess(AuthMethod method) async {
    try {
      _config = await _authService.handleAuthSuccess(_config);
      _isAuthenticated = true;
      _currentAuthMethod = method;
      _startSessionTimer();
      _stopLockoutTimer();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('处理认证成功失败: $e');
      }
    }
  }

  /// 处理认证失败
  Future<void> _handleAuthFailure() async {
    try {
      _config = await _authService.handleAuthFailure(_config);
      
      if (_config.isLocked) {
        _startLockoutTimer();
      }
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('处理认证失败失败: $e');
      }
    }
  }

  /// 登出
  Future<void> logout() async {
    _isAuthenticated = false;
    _currentAuthMethod = AuthMethod.none;
    _stopSessionTimer();
    _clearError();
    notifyListeners();
  }

  /// 启用生物识别认证
  Future<void> enableBiometric() async {
    try {
      await _checkBiometricCapability();
      
      if (!_biometricCapability.isUsable) {
        _setError(AuthError.biometricNotAvailable, '设备不支持生物识别');
        return;
      }

      _config = _config.copyWith(biometricEnabled: true);
      await _authService.saveAuthConfig(_config);
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError(AuthError.systemError, '启用生物识别失败: $e');
    }
  }

  /// 禁用生物识别认证
  Future<void> disableBiometric() async {
    try {
      _config = _config.copyWith(biometricEnabled: false);
      await _authService.saveAuthConfig(_config);
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError(AuthError.systemError, '禁用生物识别失败: $e');
    }
  }

  /// 设置密码
  Future<void> setPassword(String password) async {
    try {
      await _authService.setPassword(password);
      _config = _config.copyWith(passwordEnabled: true);
      await _authService.saveAuthConfig(_config);
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError(AuthError.systemError, '设置密码失败: $e');
    }
  }

  /// 禁用密码认证
  Future<void> disablePassword() async {
    try {
      await _authService.removePassword();
      _config = _config.copyWith(passwordEnabled: false);
      await _authService.saveAuthConfig(_config);
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError(AuthError.systemError, '禁用密码失败: $e');
    }
  }

  /// 更新认证超时时间
  Future<void> updateAuthTimeout(int minutes) async {
    try {
      _config = _config.copyWith(authTimeoutMinutes: minutes);
      await _authService.saveAuthConfig(_config);
      
      // 如果当前已认证，重新启动会话定时器
      if (_isAuthenticated) {
        _startSessionTimer();
      }
      
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError(AuthError.systemError, '更新超时设置失败: $e');
    }
  }

  /// 更新主题模式
  Future<void> updateThemeMode(ThemeMode themeMode) async {
    try {
      _config = _config.copyWith(themeMode: themeMode);
      await _authService.saveAuthConfig(_config);
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError(AuthError.systemError, '更新主题失败: $e');
    }
  }

  /// 获取推荐的认证方法
  Future<AuthMethod> getRecommendedAuthMethod() async {
    try {
      return await _authService.getRecommendedAuthMethod(_config);
    } catch (e) {
      return AuthMethod.none;
    }
  }

  /// 启动会话定时器
  void _startSessionTimer() {
    _stopSessionTimer();
    
    final timeoutDuration = Duration(minutes: _config.authTimeoutMinutes);
    _sessionTimer = Timer(timeoutDuration, () {
      logout();
    });
  }

  /// 停止会话定时器
  void _stopSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = null;
  }

  /// 启动锁定定时器
  void _startLockoutTimer() {
    _stopLockoutTimer();
    
    final remaining = lockoutRemaining;
    if (remaining != null && remaining.inMilliseconds > 0) {
      _lockoutTimer = Timer(remaining, () {
        // 锁定时间结束，重新加载配置
        _loadConfig().then((_) => notifyListeners());
      });
    }
  }

  /// 停止锁定定时器
  void _stopLockoutTimer() {
    _lockoutTimer?.cancel();
    _lockoutTimer = null;
  }

  /// 设置应用生命周期监听
  void _setupAppLifecycleListener() {
    SystemChannels.lifecycle.setMessageHandler((message) async {
      if (message == AppLifecycleState.paused.toString()) {
        // 应用进入后台，5分钟后需要重新认证
        Timer(const Duration(minutes: 5), () {
          if (_isAuthenticated) {
            logout();
          }
        });
      } else if (message == AppLifecycleState.resumed.toString()) {
        // 应用恢复，检查是否需要重新认证
        if (_isAuthenticated && !_config.isAuthValid) {
          logout();
        }
      }
      return null;
    });
  }

  /// 设置错误
  void _setError(AuthError error, String message) {
    _lastError = error;
    _errorMessage = message;
    notifyListeners();
  }

  /// 清除错误
  void _clearError() {
    _lastError = null;
    _errorMessage = null;
  }

  /// 清除所有认证数据
  Future<void> clearAllAuthData() async {
    try {
      await _authService.clearAllAuthData();
      _config = const AuthConfig();
      _isAuthenticated = false;
      _currentAuthMethod = AuthMethod.none;
      _stopSessionTimer();
      _stopLockoutTimer();
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError(AuthError.systemError, '清除认证数据失败: $e');
    }
  }

  @override
  void dispose() {
    _stopSessionTimer();
    _stopLockoutTimer();
    _isInitialized = false;
    _isInitializing = false;
    _lastBiometricCheck = null;
    super.dispose();
  }
}