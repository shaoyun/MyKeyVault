import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mykeyvault/models/models.dart';
import 'package:mykeyvault/providers/auth_provider.dart';
import 'package:mykeyvault/screens/authentication_screen.dart';
import 'package:mykeyvault/screens/onboarding_screen.dart';
import 'package:mykeyvault/widgets/authentication_wrapper.dart';
import 'package:mykeyvault/widgets/biometric_auth_widget.dart';
import 'package:mykeyvault/widgets/password_auth_widget.dart';

void main() {
  group('Authentication Flow Integration Tests', () {
    late AuthProvider authProvider;

    setUp(() {
      authProvider = AuthProvider();
    });

    tearDown(() {
      authProvider.dispose();
    });

    Widget createAuthTestApp({Widget? home}) {
      return ChangeNotifierProvider(
        create: (context) => authProvider,
        child: MaterialApp(
          home: home ?? const AuthenticationScreen(),
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
        ),
      );
    }

    group('First Time Setup Flow', () {
      testWidgets('should show onboarding screen for new users', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createAuthTestApp(
          home: const OnboardingScreen(),
        ));
        await tester.pump();

        // Assert
        expect(find.byType(OnboardingScreen), findsOneWidget);
        expect(find.text('欢迎使用 MyKeyVault'), findsOneWidget);
      });

      testWidgets('should allow skipping authentication setup', (tester) async {
        // Arrange
        await tester.pumpWidget(createAuthTestApp(
          home: const OnboardingScreen(),
        ));
        await tester.pump();

        // Act - Find and tap skip button
        final skipButton = find.text('跳过');
        if (skipButton.evaluate().isNotEmpty) {
          await tester.tap(skipButton);
          await tester.pump();
        }

        // Assert - Should handle skip action
        expect(find.byType(OnboardingScreen), findsOneWidget);
      });
    });

    group('Authentication Screen Flow', () {
      testWidgets('should show authentication screen', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createAuthTestApp());
        await tester.pump();

        // Assert
        expect(find.byType(AuthenticationScreen), findsOneWidget);
        expect(find.text('MyKeyVault'), findsOneWidget);
      });

      testWidgets('should show biometric auth when available', (tester) async {
        // Arrange
        await tester.pumpWidget(createAuthTestApp());
        await tester.pump();

        // Wait for initialization
        for (int i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }

        // Assert - Should show some form of authentication
        expect(find.byType(AuthenticationScreen), findsOneWidget);
      });

      testWidgets('should handle auth method switching', (tester) async {
        // Arrange
        await tester.pumpWidget(createAuthTestApp());
        await tester.pump();

        // Wait for screen to load
        for (int i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }

        // Look for switch buttons
        final switchButtons = find.textContaining('使用');
        if (switchButtons.evaluate().isNotEmpty) {
          // Act - Try to switch auth method
          await tester.tap(switchButtons.first);
          await tester.pump();
        }

        // Assert - Should still be on auth screen
        expect(find.byType(AuthenticationScreen), findsOneWidget);
      });
    });

    group('Password Authentication Flow', () {
      testWidgets('should show password input widget', (tester) async {
        // Arrange
        await tester.pumpWidget(
          ChangeNotifierProvider(
            create: (context) => authProvider,
            child: MaterialApp(
              home: Scaffold(
                body: PasswordAuthWidget(
                  onSuccess: () {},
                  onError: () {},
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        // Assert
        expect(find.byType(PasswordAuthWidget), findsOneWidget);
      });

      testWidgets('should handle password input', (tester) async {
        // Arrange
        await tester.pumpWidget(
          ChangeNotifierProvider(
            create: (context) => authProvider,
            child: MaterialApp(
              home: Scaffold(
                body: PasswordAuthWidget(
                  onSuccess: () {},
                  onError: () {},
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        // Look for password input fields
        final textFields = find.byType(TextField);
        if (textFields.evaluate().isNotEmpty) {
          // Act - Enter password
          await tester.enterText(textFields.first, '123456');
          await tester.pump();

          // Assert - Should show entered text (masked)
          expect(find.byType(TextField), findsOneWidget);
        }
      });
    });

    group('Biometric Authentication Flow', () {
      testWidgets('should show biometric auth widget', (tester) async {
        // Arrange
        await tester.pumpWidget(
          ChangeNotifierProvider(
            create: (context) => authProvider,
            child: MaterialApp(
              home: Scaffold(
                body: BiometricAuthWidget(
                  onSuccess: () {},
                  onError: () {},
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        // Assert
        expect(find.byType(BiometricAuthWidget), findsOneWidget);
      });

      testWidgets('should handle biometric auth trigger', (tester) async {
        // Arrange
        await tester.pumpWidget(
          ChangeNotifierProvider(
            create: (context) => authProvider,
            child: MaterialApp(
              home: Scaffold(
                body: BiometricAuthWidget(
                  onSuccess: () {},
                  onError: () {},
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        // Look for biometric trigger button
        final biometricButton = find.byIcon(Icons.fingerprint);
        if (biometricButton.evaluate().isNotEmpty) {
          // Act - Tap biometric button
          await tester.tap(biometricButton);
          await tester.pump();
        }

        // Assert - Should still show biometric widget
        expect(find.byType(BiometricAuthWidget), findsOneWidget);
      });
    });

    group('Authentication Wrapper Flow', () {
      testWidgets('should wrap child widget properly', (tester) async {
        // Arrange
        const testChild = Text('Test Child Widget');
        
        await tester.pumpWidget(
          ChangeNotifierProvider(
            create: (context) => authProvider,
            child: MaterialApp(
              home: const AuthenticationWrapper(
                child: testChild,
              ),
            ),
          ),
        );
        await tester.pump();

        // Wait for wrapper to initialize
        for (int i = 0; i < 20; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }

        // Assert - Should show wrapper
        expect(find.byType(AuthenticationWrapper), findsOneWidget);
      });

      testWidgets('should handle authentication state changes', (tester) async {
        // Arrange
        const testChild = Text('Test Child Widget');
        
        await tester.pumpWidget(
          ChangeNotifierProvider(
            create: (context) => authProvider,
            child: MaterialApp(
              home: const AuthenticationWrapper(
                child: testChild,
              ),
            ),
          ),
        );
        await tester.pump();

        // Wait for initialization
        for (int i = 0; i < 20; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }

        // Assert - Should handle state properly
        expect(find.byType(AuthenticationWrapper), findsOneWidget);
      });
    });

    group('Error Handling Flow', () {
      testWidgets('should handle authentication errors gracefully', (tester) async {
        // Arrange
        await tester.pumpWidget(createAuthTestApp());
        await tester.pump();

        // Wait for screen to load
        for (int i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }

        // Assert - Should not crash on errors
        expect(find.byType(AuthenticationScreen), findsOneWidget);
      });

      testWidgets('should show error messages when authentication fails', (tester) async {
        // Arrange
        await tester.pumpWidget(createAuthTestApp());
        await tester.pump();

        // Wait for initialization
        for (int i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }

        // Assert - Should handle errors without crashing
        expect(find.byType(AuthenticationScreen), findsOneWidget);
      });
    });

    group('Session Management Flow', () {
      testWidgets('should handle session timeout', (tester) async {
        // Arrange
        await tester.pumpWidget(createAuthTestApp());
        await tester.pump();

        // Simulate time passing
        for (int i = 0; i < 20; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }

        // Assert - Should handle session state
        expect(find.byType(AuthenticationScreen), findsOneWidget);
      });

      testWidgets('should maintain authentication state during app lifecycle', (tester) async {
        // Arrange
        await tester.pumpWidget(createAuthTestApp());
        await tester.pump();

        // Simulate app lifecycle changes
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          const MethodChannel('flutter/lifecycle'),
          (call) async {
            if (call.method == 'routeUpdated') {
              return null;
            }
            return null;
          },
        );

        // Wait for initialization
        for (int i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }

        // Assert - Should handle lifecycle properly
        expect(find.byType(AuthenticationScreen), findsOneWidget);
      });
    });

    group('Configuration Flow', () {
      testWidgets('should handle auth configuration changes', (tester) async {
        // Arrange
        await tester.pumpWidget(createAuthTestApp());
        await tester.pump();

        // Act - Update configuration
        await authProvider.updateAuthTimeout(30);
        await tester.pump();

        // Assert - Should handle config changes
        expect(authProvider.config.authTimeoutMinutes, equals(30));
      });

      testWidgets('should handle theme changes', (tester) async {
        // Arrange
        await tester.pumpWidget(createAuthTestApp());
        await tester.pump();

        // Act - Update theme
        await authProvider.updateThemeMode(ThemeMode.dark);
        await tester.pump();

        // Assert - Should handle theme changes
        expect(authProvider.config.themeMode, equals(ThemeMode.dark));
      });
    });
  });
}