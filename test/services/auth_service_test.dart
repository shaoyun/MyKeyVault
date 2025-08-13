import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mykeyvault/models/models.dart';
import 'package:mykeyvault/services/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthService', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
    });

    group('Password Management', () {
      test('should validate password format', () async {
        // Test valid password
        expect(() => authService.setPassword('123456'), returnsNormally);

        // Test invalid passwords
        expect(
          () => authService.setPassword('12345'),
          throwsA(isA<AuthException>()),
        );
        expect(
          () => authService.setPassword('1234567'),
          throwsA(isA<AuthException>()),
        );
        expect(
          () => authService.setPassword('12345a'),
          throwsA(isA<AuthException>()),
        );
      });
    });

    group('Auth Config Management', () {
      test('should handle auth success correctly', () async {
        // Arrange
        final config = AuthConfig(
          biometricEnabled: true,
          failedAttempts: 2,
          lockoutEndTime: DateTime.now().add(Duration(seconds: 30)),
        );

        // Act
        final updatedConfig = await authService.handleAuthSuccess(config);

        // Assert
        expect(updatedConfig.failedAttempts, equals(0));
        expect(updatedConfig.lockoutEndTime, isNull);
        expect(updatedConfig.lastAuthTime, isNotNull);
      });

      test('should handle auth failure correctly', () async {
        // Arrange
        final config = AuthConfig(
          biometricEnabled: true,
          failedAttempts: 2,
        );

        // Act
        final updatedConfig = await authService.handleAuthFailure(config);

        // Assert
        expect(updatedConfig.failedAttempts, equals(3));
        expect(updatedConfig.lockoutEndTime, isNotNull);
      });

      test('should check if auth is valid', () {
        // Test valid auth
        final validConfig = AuthConfig(
          lastAuthTime: DateTime.now().subtract(Duration(minutes: 10)),
          authTimeoutMinutes: 15,
        );
        expect(authService.isAuthValid(validConfig), isTrue);

        // Test expired auth
        final expiredConfig = AuthConfig(
          lastAuthTime: DateTime.now().subtract(Duration(minutes: 20)),
          authTimeoutMinutes: 15,
        );
        expect(authService.isAuthValid(expiredConfig), isFalse);

        // Test no auth
        final noAuthConfig = AuthConfig();
        expect(authService.isAuthValid(noAuthConfig), isFalse);
      });

      test('should check lockout status', () {
        // Test not locked
        final notLockedConfig = AuthConfig();
        expect(authService.isLocked(notLockedConfig), isFalse);

        // Test locked
        final lockedConfig = AuthConfig(
          lockoutEndTime: DateTime.now().add(Duration(seconds: 30)),
        );
        expect(authService.isLocked(lockedConfig), isTrue);

        // Test expired lockout
        final expiredLockoutConfig = AuthConfig(
          lockoutEndTime: DateTime.now().subtract(Duration(seconds: 30)),
        );
        expect(authService.isLocked(expiredLockoutConfig), isFalse);
      });
    });

    group('Recommended Auth Method', () {
      test('should return none when locked', () async {
        // Arrange
        final lockedConfig = AuthConfig(
          biometricEnabled: true,
          passwordEnabled: true,
          lockoutEndTime: DateTime.now().add(Duration(seconds: 30)),
        );

        // Act
        final method = await authService.getRecommendedAuthMethod(lockedConfig);

        // Assert
        expect(method, equals(AuthMethod.none));
      });

      test('should return password when only password enabled', () async {
        // Arrange
        final passwordOnlyConfig = AuthConfig(
          passwordEnabled: true,
          biometricEnabled: false,
        );

        // Act
        final method = await authService.getRecommendedAuthMethod(passwordOnlyConfig);

        // Assert
        expect(method, equals(AuthMethod.password));
      });

      test('should return none when no auth enabled', () async {
        // Arrange
        final noAuthConfig = AuthConfig();

        // Act
        final method = await authService.getRecommendedAuthMethod(noAuthConfig);

        // Assert
        expect(method, equals(AuthMethod.none));
      });
    });
  });
}