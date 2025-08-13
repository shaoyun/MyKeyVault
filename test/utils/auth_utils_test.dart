import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mykeyvault/models/models.dart';
import 'package:mykeyvault/utils/auth_utils.dart';

void main() {
  group('AuthFeedback', () {
    testWidgets('should show error snackbar', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  AuthFeedback.showError(context, AuthError.passwordIncorrect);
                },
                child: const Text('Show Error'),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Show Error'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('密码错误'), findsOneWidget);
    });

    testWidgets('should show success snackbar', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  AuthFeedback.showSuccess(context);
                },
                child: const Text('Show Success'),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Show Success'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('认证成功'), findsOneWidget);
    });

    testWidgets('should show confirm dialog', (tester) async {
      // Arrange
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  result = await AuthFeedback.showConfirmDialog(
                    context,
                    title: '确认操作',
                    content: '您确定要执行此操作吗？',
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('确认操作'), findsOneWidget);
      expect(find.text('您确定要执行此操作吗？'), findsOneWidget);

      // Tap confirm
      await tester.tap(find.text('确定'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
    });

    testWidgets('should show biometric setup guide', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  AuthFeedback.showBiometricSetupGuide(context);
                },
                child: const Text('Show Guide'),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Show Guide'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('设置生物识别'), findsOneWidget);
      expect(find.text('要使用生物识别认证，请按以下步骤设置：'), findsOneWidget);
    });
  });

  group('AuthErrorExtension', () {
    test('should provide user friendly messages', () {
      expect(
        AuthError.biometricNotAvailable.userFriendlyMessage,
        contains('不支持生物识别功能'),
      );
      expect(
        AuthError.passwordIncorrect.userFriendlyMessage,
        contains('密码错误'),
      );
    });

    test('should provide suggestions', () {
      expect(
        AuthError.biometricNotEnrolled.suggestion,
        contains('前往设置'),
      );
      expect(
        AuthError.tooManyAttempts.suggestion,
        contains('等待锁定时间'),
      );
    });

    test('should provide appropriate icons', () {
      expect(AuthError.biometricNotAvailable.icon, equals(Icons.fingerprint_outlined));
      expect(AuthError.passwordIncorrect.icon, equals(Icons.password));
      expect(AuthError.tooManyAttempts.icon, equals(Icons.block));
    });
  });
}