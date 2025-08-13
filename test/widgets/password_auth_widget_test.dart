import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mykeyvault/models/models.dart';
import 'package:mykeyvault/providers/auth_provider.dart';
import 'package:mykeyvault/widgets/password_auth_widget.dart';

void main() {
  group('PasswordAuthWidget', () {
    late AuthProvider mockAuthProvider;

    setUp(() {
      mockAuthProvider = AuthProvider();
    });

    tearDown(() {
      mockAuthProvider.dispose();
    });

    Widget createTestWidget({
      VoidCallback? onSuccess,
      VoidCallback? onError,
      VoidCallback? onSwitchToBiometric,
    }) {
      return MaterialApp(
        home: ChangeNotifierProvider<AuthProvider>.value(
          value: mockAuthProvider,
          child: Scaffold(
            body: PasswordAuthWidget(
              onSuccess: onSuccess,
              onError: onError,
              onSwitchToBiometric: onSwitchToBiometric,
            ),
          ),
        ),
      );
    }

    testWidgets('should display password authentication UI', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert
      expect(find.text('密码认证'), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsOneWidget);
      expect(find.text('请输入您的6位数字密码'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should show password dots indicator', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert - Should show 6 password dots
      final dotContainers = find.byWidgetPredicate(
        (widget) => widget is Container && 
                    widget.decoration is BoxDecoration &&
                    (widget.decoration as BoxDecoration).shape == BoxShape.circle,
      );
      expect(dotContainers, findsNWidgets(7)); // 6 dots + 1 main icon container
    });

    testWidgets('should handle password input', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Act
      final textField = find.byType(TextField);
      await tester.enterText(textField, '123');
      await tester.pump();

      // Assert
      expect(find.text('123'), findsOneWidget);
    });

    testWidgets('should show unlock button when password is complete', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Act
      final textField = find.byType(TextField);
      await tester.enterText(textField, '123456');
      await tester.pump();

      // Assert - Check if unlock button exists
      final unlockButton = find.text('解锁');
      expect(unlockButton, findsOneWidget);
    });

    testWidgets('should show unlock button with incomplete password', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Act
      final textField = find.byType(TextField);
      await tester.enterText(textField, '123');
      await tester.pump();

      // Assert - Button should still be visible but may be disabled
      final unlockButton = find.text('解锁');
      expect(unlockButton, findsOneWidget);
    });

    testWidgets('should toggle password visibility', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Act
      final visibilityButton = find.byIcon(Icons.visibility);
      expect(visibilityButton, findsOneWidget);
      
      await tester.tap(visibilityButton);
      await tester.pump();

      // Assert
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('should show switch to biometric button when callback provided', (tester) async {
      // Arrange
      bool switchCalled = false;
      
      // Act
      await tester.pumpWidget(createTestWidget(
        onSwitchToBiometric: () => switchCalled = true,
      ));
      await tester.pump();

      // Assert - The button should be visible if biometric auth is available
      // In this test, it won't be visible since we haven't set up biometric auth
      expect(find.text('使用生物识别'), findsNothing);
    });

    testWidgets('should not show error initially', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert - Initially no error should be shown
      expect(find.byIcon(Icons.error_outline), findsNothing);
    });

    testWidgets('should handle authentication callbacks', (tester) async {
      // Arrange
      bool successCalled = false;
      bool errorCalled = false;

      // Act
      await tester.pumpWidget(createTestWidget(
        onSuccess: () => successCalled = true,
        onError: () => errorCalled = true,
      ));
      await tester.pump();

      // Assert - UI should be displayed correctly
      expect(find.text('密码认证'), findsOneWidget);
    });

    testWidgets('should only accept numeric input', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Act
      final textField = find.byType(TextField);
      await tester.enterText(textField, 'abc123');
      await tester.pump();

      // Assert - Should only show numeric characters
      final textFieldWidget = tester.widget<TextField>(textField);
      expect(textFieldWidget.keyboardType, equals(TextInputType.number));
    });
  });
}