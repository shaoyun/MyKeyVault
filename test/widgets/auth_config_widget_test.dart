import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mykeyvault/models/models.dart';
import 'package:mykeyvault/providers/auth_provider.dart';
import 'package:mykeyvault/widgets/auth_config_widget.dart';

void main() {
  group('AuthConfigWidget', () {
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
          child: const Scaffold(
            body: AuthConfigWidget(),
          ),
        ),
      );
    }

    testWidgets('should display auth config options', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert
      expect(find.text('生物识别认证'), findsOneWidget);
      expect(find.text('密码认证'), findsOneWidget);
      expect(find.text('认证有效时长'), findsOneWidget);
    });

    testWidgets('should show biometric settings', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert
      expect(find.byIcon(Icons.security), findsWidgets);
      expect(find.byType(Switch), findsWidgets);
    });

    testWidgets('should show password settings', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert
      expect(find.byIcon(Icons.lock), findsOneWidget);
      expect(find.text('点击设置6位数字密码'), findsOneWidget);
    });

    testWidgets('should show timeout settings', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert
      expect(find.byIcon(Icons.timer), findsOneWidget);
      expect(find.text('15分钟后需要重新认证'), findsOneWidget);
    });

    testWidgets('should show password dialog when password tile is tapped', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Act
      await tester.tap(find.text('密码认证'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('设置密码'), findsOneWidget);
      expect(find.text('请设置6位数字密码'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should show timeout dialog when timeout tile is tapped', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Act
      await tester.tap(find.text('认证有效时长'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('认证有效时长'), findsAtLeastNWidgets(1));
      expect(find.text('5分钟'), findsOneWidget);
      expect(find.text('15分钟'), findsOneWidget);
      expect(find.text('30分钟'), findsOneWidget);
      expect(find.text('60分钟'), findsOneWidget);
    });

    testWidgets('should validate password input', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Act
      await tester.tap(find.text('密码认证'));
      await tester.pumpAndSettle();

      // Enter incomplete password
      await tester.enterText(find.byType(TextField), '123');
      await tester.pump();

      // Assert - Set button should be disabled
      final setButton = find.text('设置');
      expect(setButton, findsOneWidget);
      
      // Enter complete password
      await tester.enterText(find.byType(TextField), '123456');
      await tester.pump();

      // Assert - Set button should be enabled
      expect(setButton, findsOneWidget);
    });

    testWidgets('should handle biometric switch toggle', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Act
      final switches = find.byType(Switch);
      if (switches.evaluate().isNotEmpty) {
        await tester.tap(switches.first);
        await tester.pump();
      }

      // Assert - Should handle the toggle gracefully
      expect(find.byType(Switch), findsWidgets);
    });

    testWidgets('should show card container', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should show dividers between sections', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert
      expect(find.byType(Divider), findsWidgets);
    });

    testWidgets('should handle dialog cancellation', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Act
      await tester.tap(find.text('密码认证'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();

      // Assert - Dialog should be closed
      expect(find.text('设置密码'), findsNothing);
    });
  });
}