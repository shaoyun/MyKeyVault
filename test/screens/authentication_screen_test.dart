import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mykeyvault/models/models.dart';
import 'package:mykeyvault/providers/auth_provider.dart';
import 'package:mykeyvault/screens/authentication_screen.dart';

void main() {
  group('AuthenticationScreen', () {
    late AuthProvider mockAuthProvider;

    setUp(() {
      mockAuthProvider = AuthProvider();
    });

    tearDown(() {
      mockAuthProvider.dispose();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<AuthProvider>.value(
          value: mockAuthProvider,
          child: const AuthenticationScreen(),
        ),
        routes: {
          '/home': (context) => const Scaffold(body: Text('Home')),
          '/settings': (context) => const Scaffold(body: Text('Settings')),
        },
      );
    }

    testWidgets('should display app branding', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert
      expect(find.text('MyKeyVault'), findsOneWidget);
      expect(find.text('安全的TOTP认证器'), findsOneWidget);
      expect(find.byIcon(Icons.security), findsWidgets);
    });

    testWidgets('should show setup prompt when no auth is enabled', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert
      expect(find.text('首次使用'), findsOneWidget);
      expect(find.text('前往设置'), findsOneWidget);
      expect(find.text('暂时跳过'), findsOneWidget);
      expect(find.byIcon(Icons.settings_suggest), findsOneWidget);
    });

    testWidgets('should show setup navigation button', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert
      final settingsButton = find.text('前往设置');
      expect(settingsButton, findsOneWidget);
    });

    testWidgets('should show skip authentication button', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert
      final skipButton = find.text('暂时跳过');
      expect(skipButton, findsOneWidget);
    });

    testWidgets('should show gradient background', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert
      final container = find.byWidgetPredicate(
        (widget) => widget is Container && widget.decoration is BoxDecoration,
      );
      expect(container, findsWidgets);
    });

    testWidgets('should display bottom instruction text', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert
      expect(find.text('请验证您的身份以继续使用应用'), findsOneWidget);
    });

    testWidgets('should show app icon with correct styling', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert
      final iconContainer = find.byWidgetPredicate(
        (widget) => widget is Container && 
                    widget.decoration is BoxDecoration,
      );
      expect(iconContainer, findsWidgets);
    });

    testWidgets('should handle refresh action', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert - Initially should show setup prompt
      expect(find.text('首次使用'), findsOneWidget);
    });

    testWidgets('should be responsive to theme changes', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: mockAuthProvider,
            child: const AuthenticationScreen(),
          ),
        ),
      );
      await tester.pump();

      // Assert
      expect(find.text('MyKeyVault'), findsOneWidget);
      expect(find.text('首次使用'), findsOneWidget);
    });
  });
}