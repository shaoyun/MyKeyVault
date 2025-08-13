import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mykeyvault/models/models.dart';
import 'package:mykeyvault/providers/auth_provider.dart';
import 'package:mykeyvault/screens/onboarding_screen.dart';

void main() {
  group('OnboardingScreen', () {
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
          child: const OnboardingScreen(),
        ),
        routes: {
          '/home': (context) => const Scaffold(body: Text('Home')),
          '/settings': (context) => const Scaffold(body: Text('Settings')),
        },
      );
    }

    testWidgets('should display welcome page initially', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert
      expect(find.text('欢迎使用 MyKeyVault'), findsOneWidget);
      expect(find.text('安全的TOTP认证器，保护您的数字身份'), findsOneWidget);
      expect(find.text('开始使用'), findsOneWidget);
    });

    testWidgets('should show page indicators', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert - Should show 3 page indicators
      final indicators = find.byWidgetPredicate(
        (widget) => widget is Container && 
                    widget.decoration is BoxDecoration &&
                    (widget.decoration as BoxDecoration).shape == BoxShape.circle,
      );
      expect(indicators, findsNWidgets(4)); // 3 indicators + 1 app icon
    });

    testWidgets('should navigate to next page when button is tapped', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Act
      await tester.tap(find.text('开始使用'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('保护您的账户'), findsOneWidget);
      expect(find.text('MyKeyVault 使用多层安全保护'), findsOneWidget);
    });

    testWidgets('should show skip button', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert
      expect(find.text('跳过'), findsOneWidget);
    });

    testWidgets('should show feature items on welcome page', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert
      expect(find.text('生物识别保护'), findsOneWidget);
      expect(find.text('密码备用认证'), findsOneWidget);
      expect(find.text('本地安全存储'), findsOneWidget);
    });

    testWidgets('should show security features on second page', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Act - Navigate to second page
      await tester.tap(find.text('开始使用'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('端到端加密'), findsOneWidget);
      expect(find.text('本地存储'), findsOneWidget);
      expect(find.text('会话超时'), findsOneWidget);
    });

    testWidgets('should show setup options on third page', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Act - Navigate to third page
      await tester.tap(find.text('开始使用'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('了解了'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('设置认证方式'), findsOneWidget);
      expect(find.text('密码认证'), findsOneWidget);
      expect(find.text('暂时跳过，稍后设置'), findsOneWidget);
    });

    testWidgets('should show previous button on later pages', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Act - Navigate to second page
      await tester.tap(find.text('开始使用'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('上一步'), findsOneWidget);
    });

    testWidgets('should handle password setup dialog', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Navigate to setup page
      await tester.tap(find.text('开始使用'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('了解了'));
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('密码认证'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('设置密码'), findsOneWidget);
      expect(find.text('请设置一个6位数字密码'), findsOneWidget);
    });

    testWidgets('should show app icon and branding', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert
      expect(find.byIcon(Icons.security), findsWidgets);
      expect(find.text('MyKeyVault'), findsOneWidget);
    });

    testWidgets('should handle page navigation with PageView', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Act - Swipe to next page
      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      await tester.pumpAndSettle();

      // Assert - Should be on second page
      expect(find.text('保护您的账户'), findsOneWidget);
    });
  });
}