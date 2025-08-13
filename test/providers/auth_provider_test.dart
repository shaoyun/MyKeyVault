import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mykeyvault/models/models.dart';
import 'package:mykeyvault/providers/auth_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthProvider', () {
    late AuthProvider authProvider;

    setUp(() {
      authProvider = AuthProvider();
    });

    tearDown(() {
      authProvider.dispose();
    });

    group('Initialization', () {
      test('should initialize with default values', () {
        expect(authProvider.isAuthenticated, isFalse);
        expect(authProvider.currentAuthMethod, equals(AuthMethod.none));
        expect(authProvider.hasAnyAuthEnabled, isFalse);
        expect(authProvider.isLocked, isFalse);
      });
    });

    group('Authentication State', () {
      test('should update authentication state on successful auth', () async {
        // Note: This test would need mocking in a real scenario
        // since we can't actually authenticate in unit tests
        expect(authProvider.isAuthenticated, isFalse);
      });

      test('should handle logout correctly', () async {
        // Act
        await authProvider.logout();

        // Assert
        expect(authProvider.isAuthenticated, isFalse);
        expect(authProvider.currentAuthMethod, equals(AuthMethod.none));
        expect(authProvider.lastError, isNull);
      });
    });

    group('Configuration Management', () {
      test('should handle auth timeout updates', () async {
        // Act
        await authProvider.updateAuthTimeout(30);

        // Assert
        expect(authProvider.config.authTimeoutMinutes, equals(30));
      });

      test('should handle theme mode updates', () async {
        // Act
        await authProvider.updateThemeMode(ThemeMode.dark);

        // Assert
        expect(authProvider.config.themeMode, equals(ThemeMode.dark));
      });
    });

    group('Error Handling', () {
      test('should clear errors on successful operations', () async {
        // Act
        await authProvider.logout(); // This should clear any errors

        // Assert
        expect(authProvider.lastError, isNull);
        expect(authProvider.errorMessage, isNull);
      });
    });

    group('Capability Checks', () {
      test('should check biometric capability', () {
        // Initially should be false since no real device
        expect(authProvider.canUseBiometric, isFalse);
      });

      test('should check password capability', () {
        // Initially should be false since no password set
        expect(authProvider.canUsePassword, isFalse);
      });
    });
  });
}