import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mykeyvault/providers/account_provider.dart';
import 'package:mykeyvault/providers/auth_provider.dart';
import 'package:mykeyvault/screens/home_screen.dart';
import 'package:mykeyvault/screens/settings_screen.dart';
import 'package:mykeyvault/widgets/authentication_wrapper.dart';

void main() {
  group('App Integration Tests', () {
    late AccountProvider accountProvider;
    late AuthProvider authProvider;

    setUp(() {
      accountProvider = AccountProvider();
      authProvider = AuthProvider();
    });

    tearDown(() {
      authProvider.dispose();
    });

    Widget createTestApp() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => accountProvider),
          ChangeNotifierProvider(create: (context) => authProvider),
        ],
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return MaterialApp(
              title: 'MyKeyVault',
              theme: ThemeData.light(),
              darkTheme: ThemeData.dark(),
              themeMode: authProvider.config.themeMode,
              home: const AuthenticationWrapper(
                child: HomeScreen(),
              ),
              routes: {
                '/home': (context) => const AuthenticationWrapper(
                  child: HomeScreen(),
                ),
                '/settings': (context) => const SettingsScreen(),
              },
            );
          },
        ),
      );
    }

    testWidgets('should launch app and show authentication or home screen', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestApp());
      await tester.pump();

      // Assert - Should show either authentication screen or home screen
      expect(find.byType(MaterialApp), findsOneWidget);
      
      // Should show some UI content
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should show MyKeyVault branding', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestApp());
      await tester.pump();

      // Wait for initialization
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Assert - Should show app name somewhere
      expect(find.text('MyKeyVault'), findsAtLeastNWidgets(1));
    });

    testWidgets('should handle theme changes', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestApp());
      await tester.pump();

      // Assert - Should have theme data
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme, isNotNull);
      expect(materialApp.darkTheme, isNotNull);
    });

    testWidgets('should have proper navigation structure', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestApp());
      await tester.pump();

      // Assert - Should have routes configured
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.routes, isNotNull);
      expect(materialApp.routes!.containsKey('/home'), isTrue);
      expect(materialApp.routes!.containsKey('/settings'), isTrue);
    });

    testWidgets('should show settings button in home screen', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestApp());
      await tester.pump();

      // Wait for potential authentication to complete
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Assert - Should show settings button if on home screen
      // Note: This might not be visible if authentication is required
      final settingsButton = find.byIcon(Icons.settings);
      // In test environment, should eventually show home screen
      expect(settingsButton, findsAny);
    });

    testWidgets('should handle provider initialization', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestApp());
      await tester.pump();

      // Assert - Should not crash during provider initialization
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('should show proper app title', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestApp());
      await tester.pump();

      // Assert
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.title, equals('MyKeyVault'));
    });

    testWidgets('should handle authentication wrapper', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestApp());
      await tester.pump();

      // Wait for authentication wrapper to initialize
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Assert - Should show some content (either auth screen or home)
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should handle multi-provider setup', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestApp());
      await tester.pump();

      // Assert - Should not crash with multi-provider setup
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}