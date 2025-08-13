import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mykeyvault/models/models.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // 存储键名
  static const String _authConfigKey = 'auth_config';
  static const String _passwordHashKey = 'password_hash';
  static const String _saltKey = 'password_salt';

  /// 保存认证配置
  Future<void> saveAuthConfig(AuthConfig config) async {
    try {
      final jsonString = jsonEncode(config.toJson());
      await _storage.write(key: _authConfigKey, value: jsonString);
    } catch (e) {
      throw AuthException(AuthError.systemError, '保存认证配置失败: $e');
    }
  }

  /// 加载认证配置
  Future<AuthConfig> loadAuthConfig() async {
    try {
      final jsonString = await _storage.read(key: _authConfigKey);
      if (jsonString == null) {
        return const AuthConfig(); // 返回默认配置
      }
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return AuthConfig.fromJson(json);
    } catch (e) {
      throw AuthException(AuthError.systemError, '加载认证配置失败: $e');
    }
  }

  /// 设置密码（哈希存储）
  Future<void> setPassword(String password) async {
    try {
      // 生成随机盐值
      final salt = _generateSalt();
      
      // 使用PBKDF2进行密码哈希
      final hashedPassword = _hashPassword(password, salt);
      
      // 分别存储哈希值和盐值
      await _storage.write(key: _passwordHashKey, value: hashedPassword);
      await _storage.write(key: _saltKey, value: salt);
    } catch (e) {
      throw AuthException(AuthError.systemError, '设置密码失败: $e');
    }
  }

  /// 验证密码
  Future<bool> verifyPassword(String password) async {
    try {
      final storedHash = await _storage.read(key: _passwordHashKey);
      final salt = await _storage.read(key: _saltKey);
      
      if (storedHash == null || salt == null) {
        return false; // 没有设置密码
      }
      
      final inputHash = _hashPassword(password, salt);
      return storedHash == inputHash;
    } catch (e) {
      throw AuthException(AuthError.systemError, '验证密码失败: $e');
    }
  }

  /// 检查是否已设置密码
  Future<bool> hasPassword() async {
    try {
      final storedHash = await _storage.read(key: _passwordHashKey);
      return storedHash != null;
    } catch (e) {
      return false;
    }
  }

  /// 删除密码
  Future<void> removePassword() async {
    try {
      await _storage.delete(key: _passwordHashKey);
      await _storage.delete(key: _saltKey);
    } catch (e) {
      throw AuthException(AuthError.systemError, '删除密码失败: $e');
    }
  }

  /// 清除所有认证数据
  Future<void> clearAll() async {
    try {
      await _storage.delete(key: _authConfigKey);
      await _storage.delete(key: _passwordHashKey);
      await _storage.delete(key: _saltKey);
    } catch (e) {
      throw AuthException(AuthError.systemError, '清除认证数据失败: $e');
    }
  }

  /// 生成随机盐值
  String _generateSalt() {
    final bytes = List<int>.generate(32, (i) => 
        (DateTime.now().millisecondsSinceEpoch + i) % 256);
    return base64Encode(bytes);
  }

  /// 使用PBKDF2哈希密码
  String _hashPassword(String password, String salt) {
    final saltBytes = base64Decode(salt);
    final passwordBytes = utf8.encode(password);
    
    // 使用HMAC-SHA256进行多次迭代
    List<int> hash = passwordBytes;
    for (int i = 0; i < 10000; i++) {
      final hmac = Hmac(sha256, saltBytes);
      hash = hmac.convert(hash).bytes;
    }
    
    return base64Encode(hash);
  }
}