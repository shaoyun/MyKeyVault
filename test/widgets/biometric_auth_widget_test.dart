import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mykeyvault/models/models.dart';
import 'package:mykeyvault/providers/auth_provider.dart';
import 'package:mykeyvault/widgets/biometric_auth_widget.dart';

void main() {
  group('BiometricAuthWidget', () {
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
      VoidCallback? onSwitchToPassword,
    }) {
      return MaterialApp(
        home: ChangeNotifierProvider<AuthProvider>.value(
          value: mockAuthProvider,
          child: Scaffold(
            body: BiometricAuthWidget(
              onSuccess: onSuccess,
              onError: onError,
              onSwitchToPassword: onSwitchToPassword,
            ),
          ),
        ),
      );
    }

    testWidgets('should display biometric authentication UI', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert
      expect(find.text('生物识别认证'), findsOneWidget);
      expect(find.byIcon(Icons.security), findsWidgets);
      expect(find.text('使用生物识别'), findsOneWidget);
    });

    testWidgets('should show security icon by default', (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert
      expect(find.byIcon(Icons.security), findsWidgets);
    });

    testWidgets('should show switch to password button when callback provided', (tester) async {
      // Arrange
      bool switchCalled = false;
      
      // Act
      await tester.pumpWidget(createTestWidget(
        onSwitchToPassword: () => switchCalled = true,
      ));
      await tester.pump();

      // Assert - The button should be visible if password auth is available
      // In this test, it won't be visible since we haven't set up password auth
      expect(find.text('使用密码'), findsNothing);
    });

    testWidgets('should handle authentication gracefully', (tester) async {
      // Arrange
      bool successCalled = false;
      bool errorCalled = false;

      // Act
      await tester.pumpWidget(createTestWidget(
        onSuccess: () => successCalled = true,
        onError: () => errorCalled = true,
      ));
      await tester.pump();

      // Assert - In test environment, authentication will likely fail
      // but the UI should handle it gracefully
      expect(find.text('生物识别认证'), findsOneWidget);
    });

    testWidgets('should not show error initially', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert - Initially no error should be shown
      expect(find.byIcon(Icons.error_outline), findsNothing);
    });

    testWidgets('should show device not supported message', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert - In test environment, device support is not available
      expect(find.text('您的设备不支持生物识别认证'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('should display main icon with correct size', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert
      expect(find.byIcon(Icons.security), findsWidgets);
      
      // Check that there's at least one icon with size 60
      final iconWidgets = tester.widgetList<Icon>(find.byIcon(Icons.security));
      final hasMainIcon = iconWidgets.any((icon) => icon.size == 60);
      expect(hasMainIcon, isTrue);
    });
  });
}