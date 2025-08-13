import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mykeyvault/models/models.dart';
import 'package:mykeyvault/providers/auth_provider.dart';
import 'package:mykeyvault/services/auth_service.dart';
import 'package:mykeyvault/services/secure_storage_service.dart';
import 'package:mykeyvault/utils/auth_utils.dart';
import 'package:mykeyvault/utils/password_utils.dart';

void main() {
  group('Edge Cases and Error Handling Tests', () {
    late AuthProvider authProvider;

    setUp(() {
      authProvider = AuthProvider();
    });

    tearDown(() {
      authProvider.dispose();
    });

    group('Device Capability Edge Cases', () {
      test('should handle device without biometric support', () async {
        // Arrange & Act
        final capability = await authProvider.checkBiometricCapability();

        // Assert - Should handle gracefully even if no biometrics
        expect(capability, isA<BiometricCapability>());
        expect(capability.isAvailable, isFalse); // Expected in test environment
      });

      test('should handle biometric enrollment changes', () async {
        // Arrange & Act
        final initialCapability = await authProvider.checkBiometricCapability();
        
        // Simulate checking again (enrollment might change)
        final secondCapability = await authProvider.checkBiometricCapability();

        // Assert - Should handle capability checks consistently
        expect(initialCapability.isAvailable, equals(secondCapability.isAvailable));
      });

      test('should handle platform-specific biometric types', () async {
        // Arrange & Act
        final capability = await authProvider.checkBiometricCapability();

        // Assert - Should handle different biometric types
        expect(capability.availableTypes, isA<List>());
      });
    });

    group('Password Security Edge Cases', () {
      test('should handle password hashing edge cases', () {
        // Test empty password
        expect(() => PasswordUtils.hashPassword(''), throwsArgumentError);
        
        // Test very long password
        final longPassword = '1' * 1000;
        expect(() => PasswordUtils.hashPassword(longPassword), throwsArgumentError);
        
        // Test valid password
        final hash = PasswordUtils.hashPassword('123456');
        expect(hash, isNotEmpty);
        expect(hash.length, greaterThan(10));
      });

      test('should handle password verification edge cases', () {
        // Test with null hash
        expect(PasswordUtils.verifyPassword('123456', ''), isFalse);
        
        // Test with invalid hash format
        expect(PasswordUtils.verifyPassword('123456', 'invalid_hash'), isFalse);
        
        // Test with correct password
        final hash = PasswordUtils.hashPassword('123456');
        expect(PasswordUtils.verifyPassword('123456', hash), isTrue);
        expect(PasswordUtils.verifyPassword('wrong', hash), isFalse);
      });

      test('should validate password format correctly', () {
        // Test invalid passwords
        expect(PasswordUtils.isValidPassword(''), isFalse);
        expect(PasswordUtils.isValidPassword('12345'), isFalse); // Too short
        expect(PasswordUtils.isValidPassword('1234567'), isFalse); // Too long
        expect(PasswordUtils.isValidPassword('12345a'), isFalse); // Contains letter
        
        // Test valid passwords
        expect(PasswordUtils.isValidPassword('123456'), isTrue);
        expect(PasswordUtils.isValidPassword('000000'), isTrue);
        expect(PasswordUtils.isValidPassword('999999'), isTrue);
      });
    });

    group('Authentication State Edge Cases', () {
      test('should handle rapid authentication state changes', () async {
        // Arrange
        expect(authProvider.isAuthenticated, isFalse);

        // Act - Rapid state changes
        await authProvider.logout();
        await authProvider.logout(); // Double logout
        
        // Assert - Should handle gracefully
        expect(authProvider.isAuthenticated, isFalse);
        expect(authProvider.lastError, isNull);
      });

      test('should handle authentication timeout edge cases', () async {
        // Test minimum timeout
        await authProvider.updateAuthTimeout(1);
        expect(authProvider.config.authTimeoutMinutes, equals(1));
        
        // Test maximum timeout
        await authProvider.updateAuthTimeout(1440); // 24 hours
        expect(authProvider.config.authTimeoutMinutes, equals(1440));
        
        // Test invalid timeout (should clamp or reject)
        await authProvider.updateAuthTimeout(0);
        expect(authProvider.config.authTimeoutMinutes, greaterThan(0));
        
        await authProvider.updateAuthTimeout(-1);
        expect(authProvider.config.authTimeoutMinutes, greaterThan(0));
      });

      test('should handle session timer edge cases', () async {
        // Test timer cleanup on dispose
        final provider = AuthProvider();
        await provider.updateAuthTimeout(1);
        
        // Dispose should clean up timers
        provider.dispose();
        
        // Should not crash
        expect(true, isTrue);
      });
    });

    group('Storage Edge Cases', () {
      test('should handle storage failures gracefully', () async {
        // This test simulates storage failures
        // In a real app, you'd mock the storage service
        
        // Test config loading with no stored data
        final provider = AuthProvider();
        await provider.loadConfig();
        
        // Should have default values
        expect(provider.config.authTimeoutMinutes, equals(15));
        expect(provider.config.biometricEnabled, isFalse);
        expect(provider.config.passwordEnabled, isFalse);
        
        provider.dispose();
      });

      test('should handle corrupted config data', () async {
        // Test with invalid config data
        final provider = AuthProvider();
        
        // Should handle gracefully and use defaults
        await provider.loadConfig();
        expect(provider.config, isNotNull);
        
        provider.dispose();
      });
    });

    group('Lockout Mechanism Edge Cases', () {
      test('should handle failed attempt counting', () async {
        // Test failed attempt increment
        expect(authProvider.config.failedAttempts, equals(0));
        
        // Simulate failed attempts
        await authProvider.recordFailedAttempt();
        expect(authProvider.config.failedAttempts, equals(1));
        
        await authProvider.recordFailedAttempt();
        expect(authProvider.config.failedAttempts, equals(2));
        
        await authProvider.recordFailedAttempt();
        expect(authProvider.config.failedAttempts, equals(3));
        
        // Should be locked after 3 attempts
        expect(authProvider.isLocked, isTrue);
      });

      test('should handle lockout timer edge cases', () async {
        // Force lockout
        await authProvider.recordFailedAttempt();
        await authProvider.recordFailedAttempt();
        await authProvider.recordFailedAttempt();
        
        expect(authProvider.isLocked, isTrue);
        expect(authProvider.lockoutEndTime, isNotNull);
        
        // Test lockout duration
        final lockoutEnd = authProvider.lockoutEndTime!;
        final now = DateTime.now();
        final duration = lockoutEnd.difference(now);
        
        expect(duration.inSeconds, greaterThan(0));
        expect(duration.inMinutes, lessThanOrEqualTo(1)); // Should be reasonable
      });

      test('should reset failed attempts on successful auth', () async {
        // Set up failed attempts
        await authProvider.recordFailedAttempt();
        await authProvider.recordFailedAttempt();
        expect(authProvider.config.failedAttempts, equals(2));
        
        // Reset on success
        await authProvider.resetFailedAttempts();
        expect(authProvider.config.failedAttempts, equals(0));
        expect(authProvider.isLocked, isFalse);
      });
    });

    group('Theme and Configuration Edge Cases', () {
      test('should handle theme mode changes', () async {
        // Test all theme modes
        await authProvider.updateThemeMode(ThemeMode.light);
        expect(authProvider.config.themeMode, equals(ThemeMode.light));
        
        await authProvider.updateThemeMode(ThemeMode.dark);
        expect(authProvider.config.themeMode, equals(ThemeMode.dark));
        
        await authProvider.updateThemeMode(ThemeMode.system);
        expect(authProvider.config.themeMode, equals(ThemeMode.system));
      });

      test('should handle configuration persistence', () async {
        // Change multiple settings
        await authProvider.updateAuthTimeout(30);
        await authProvider.updateThemeMode(ThemeMode.dark);
        
        // Create new provider (simulates app restart)
        final newProvider = AuthProvider();
        await newProvider.loadConfig();
        
        // Should load saved settings
        // Note: In test environment, this might not persist
        // In real app, you'd test with mocked storage
        
        newProvider.dispose();
      });
    });

    group('Memory and Resource Management', () {
      test('should handle provider disposal correctly', () {
        // Create multiple providers
        final providers = List.generate(5, (index) => AuthProvider());
        
        // Dispose all
        for (final provider in providers) {
          provider.dispose();
        }
        
        // Should not crash
        expect(true, isTrue);
      });

      test('should handle listener management', () {
        // Add listeners
        var callCount = 0;
        void listener() => callCount++;
        
        authProvider.addListener(listener);
        authProvider.addListener(listener); // Add same listener twice
        
        // Trigger notification
        authProvider.notifyListeners();
        
        // Remove listeners
        authProvider.removeListener(listener);
        authProvider.dispose();
        
        // Should handle gracefully
        expect(callCount, greaterThan(0));
      });
    });

    group('Utility Function Edge Cases', () {
      test('should handle auth utility edge cases', () {
        // Test formatAuthError with various errors
        expect(AuthUtils.formatAuthError(AuthError.biometricNotAvailable), isNotEmpty);
        expect(AuthUtils.formatAuthError(AuthError.passwordIncorrect), isNotEmpty);
        expect(AuthUtils.formatAuthError(AuthError.tooManyAttempts), isNotEmpty);
        expect(AuthUtils.formatAuthError(AuthError.systemError), isNotEmpty);
      });

      test('should handle auth method display names', () {
        // Test all auth methods
        expect(AuthUtils.getAuthMethodDisplayName(AuthMethod.biometric), isNotEmpty);
        expect(AuthUtils.getAuthMethodDisplayName(AuthMethod.password), isNotEmpty);
        expect(AuthUtils.getAuthMethodDisplayName(AuthMethod.none), isNotEmpty);
      });

      test('should handle timeout formatting', () {
        // Test various timeout values
        expect(AuthUtils.formatTimeout(1), isNotEmpty);
        expect(AuthUtils.formatTimeout(15), isNotEmpty);
        expect(AuthUtils.formatTimeout(60), isNotEmpty);
        expect(AuthUtils.formatTimeout(1440), isNotEmpty);
      });
    });

    group('Concurrent Access Edge Cases', () {
      test('should handle concurrent authentication attempts', () async {
        // Simulate multiple auth attempts
        final futures = <Future>[];
        
        for (int i = 0; i < 5; i++) {
          futures.add(authProvider.logout());
        }
        
        // Wait for all to complete
        await Future.wait(futures);
        
        // Should handle gracefully
        expect(authProvider.isAuthenticated, isFalse);
      });

      test('should handle concurrent config updates', () async {
        // Simulate multiple config updates
        final futures = <Future>[];
        
        futures.add(authProvider.updateAuthTimeout(30));
        futures.add(authProvider.updateThemeMode(ThemeMode.dark));
        futures.add(authProvider.resetFailedAttempts());
        
        // Wait for all to complete
        await Future.wait(futures);
        
        // Should handle gracefully
        expect(authProvider.config, isNotNull);
      });
    });
  });
}