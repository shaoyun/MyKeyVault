import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mykeyvault/models/models.dart';
import 'package:mykeyvault/services/secure_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('SecureStorageService', () {
    late SecureStorageService service;

    setUp(() {
      service = SecureStorageService();
    });

    group('AuthConfig', () {
      test('should save and load auth config', () async {
        // Arrange
        const config = AuthConfig(
          biometricEnabled: true,
          passwordEnabled: true,
          authTimeoutMinutes: 30,
        );

        // Act
        await service.saveAuthConfig(config);
        final loadedConfig = await service.loadAuthConfig();

        // Assert
        expect(loadedConfig.biometricEnabled, equals(true));
        expect(loadedConfig.passwordEnabled, equals(true));
        expect(loadedConfig.authTimeoutMinutes, equals(30));
      });

      test('should return default config when no config exists', () async {
        // Act
        final config = await service.loadAuthConfig();

        // Assert
        expect(config.biometricEnabled, equals(false));
        expect(config.passwordEnabled, equals(false));
        expect(config.authTimeoutMinutes, equals(15));
      });
    });

    group('Password', () {
      test('should set and verify password correctly', () async {
        // Arrange
        const password = '123456';

        // Act
        await service.setPassword(password);
        final isValid = await service.verifyPassword(password);
        final hasPassword = await service.hasPassword();

        // Assert
        expect(isValid, equals(true));
        expect(hasPassword, equals(true));
      });

      test('should reject incorrect password', () async {
        // Arrange
        const correctPassword = '123456';
        const wrongPassword = '654321';

        // Act
        await service.setPassword(correctPassword);
        final isValid = await service.verifyPassword(wrongPassword);

        // Assert
        expect(isValid, equals(false));
      });

      test('should return false when no password is set', () async {
        // Act
        final hasPassword = await service.hasPassword();
        final isValid = await service.verifyPassword('123456');

        // Assert
        expect(hasPassword, equals(false));
        expect(isValid, equals(false));
      });

      test('should remove password correctly', () async {
        // Arrange
        const password = '123456';
        await service.setPassword(password);

        // Act
        await service.removePassword();
        final hasPassword = await service.hasPassword();
        final isValid = await service.verifyPassword(password);

        // Assert
        expect(hasPassword, equals(false));
        expect(isValid, equals(false));
      });
    });

    group('Clear All', () {
      test('should clear all stored data', () async {
        // Arrange
        const config = AuthConfig(biometricEnabled: true);
        const password = '123456';
        
        await service.saveAuthConfig(config);
        await service.setPassword(password);

        // Act
        await service.clearAll();

        // Assert
        final loadedConfig = await service.loadAuthConfig();
        final hasPassword = await service.hasPassword();
        
        expect(loadedConfig.biometricEnabled, equals(false));
        expect(hasPassword, equals(false));
      });
    });
  });
}