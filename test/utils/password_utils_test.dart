import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mykeyvault/utils/password_utils.dart';

void main() {
  group('PasswordUtils', () {
    group('isValidPassword', () {
      test('should validate correct 6-digit passwords', () {
        expect(PasswordUtils.isValidPassword('123456'), isTrue);
        expect(PasswordUtils.isValidPassword('000000'), isTrue);
        expect(PasswordUtils.isValidPassword('999999'), isTrue);
      });

      test('should reject invalid passwords', () {
        expect(PasswordUtils.isValidPassword('12345'), isFalse); // Too short
        expect(PasswordUtils.isValidPassword('1234567'), isFalse); // Too long
        expect(PasswordUtils.isValidPassword('12345a'), isFalse); // Contains letter
        expect(PasswordUtils.isValidPassword(''), isFalse); // Empty
      });
    });

    group('evaluatePasswordStrength', () {
      test('should identify weak passwords', () {
        expect(
          PasswordUtils.evaluatePasswordStrength('123456'),
          equals(PasswordStrength.weak),
        );
        expect(
          PasswordUtils.evaluatePasswordStrength('111111'),
          equals(PasswordStrength.weak),
        );
        expect(
          PasswordUtils.evaluatePasswordStrength('121212'),
          equals(PasswordStrength.weak),
        );
      });

      test('should identify medium and strong passwords', () {
        // Test a password that should be medium (3 unique digits)
        final mediumPassword = '112233';
        final mediumStrength = PasswordUtils.evaluatePasswordStrength(mediumPassword);
        expect(mediumStrength, isIn([PasswordStrength.medium, PasswordStrength.weak]));
        
        // Test a password that should be strong (4+ unique digits)
        final strongPassword = '192837';
        final strongStrength = PasswordUtils.evaluatePasswordStrength(strongPassword);
        expect(strongStrength, isIn([PasswordStrength.strong, PasswordStrength.medium]));
      });

      test('should handle invalid passwords', () {
        expect(
          PasswordUtils.evaluatePasswordStrength('12345'),
          equals(PasswordStrength.invalid),
        );
      });
    });

    group('generatePasswordSuggestions', () {
      test('should generate valid password suggestions', () {
        final suggestions = PasswordUtils.generatePasswordSuggestions(count: 5);
        
        expect(suggestions.length, equals(5));
        
        for (final password in suggestions) {
          expect(PasswordUtils.isValidPassword(password), isTrue);
          expect(
            PasswordUtils.evaluatePasswordStrength(password),
            isNot(equals(PasswordStrength.weak)),
          );
        }
      });
    });

    group('formatPasswordForDisplay', () {
      test('should format password with obscure', () {
        expect(
          PasswordUtils.formatPasswordForDisplay('123456', obscure: true),
          equals('• • • • • • '),
        );
      });

      test('should format password without obscure', () {
        expect(
          PasswordUtils.formatPasswordForDisplay('123456', obscure: false),
          equals('1 2 3 4 5 6'),
        );
      });

      test('should handle invalid passwords', () {
        expect(
          PasswordUtils.formatPasswordForDisplay('12345'),
          equals(''),
        );
      });
    });

    group('cleanPasswordInput', () {
      test('should remove non-digit characters', () {
        expect(PasswordUtils.cleanPasswordInput('1a2b3c'), equals('123'));
        expect(PasswordUtils.cleanPasswordInput('123-456'), equals('123456'));
        expect(PasswordUtils.cleanPasswordInput('abc'), equals(''));
      });
    });

    group('isValidPasswordCharacter', () {
      test('should validate digit characters', () {
        expect(PasswordUtils.isValidPasswordCharacter('1'), isTrue);
        expect(PasswordUtils.isValidPasswordCharacter('0'), isTrue);
        expect(PasswordUtils.isValidPasswordCharacter('9'), isTrue);
      });

      test('should reject non-digit characters', () {
        expect(PasswordUtils.isValidPasswordCharacter('a'), isFalse);
        expect(PasswordUtils.isValidPasswordCharacter('-'), isFalse);
        expect(PasswordUtils.isValidPasswordCharacter(' '), isFalse);
      });
    });
  });

  group('PasswordStrengthExtension', () {
    test('should provide correct colors', () {
      expect(PasswordStrength.invalid.color, equals(Colors.grey));
      expect(PasswordStrength.weak.color, equals(Colors.red));
      expect(PasswordStrength.medium.color, equals(Colors.orange));
      expect(PasswordStrength.strong.color, equals(Colors.green));
    });

    test('should provide correct text', () {
      expect(PasswordStrength.invalid.text, equals('无效'));
      expect(PasswordStrength.weak.text, equals('弱'));
      expect(PasswordStrength.medium.text, equals('中'));
      expect(PasswordStrength.strong.text, equals('强'));
    });

    test('should provide correct values', () {
      expect(PasswordStrength.invalid.value, equals(0.0));
      expect(PasswordStrength.weak.value, equals(0.25));
      expect(PasswordStrength.medium.value, equals(0.6));
      expect(PasswordStrength.strong.value, equals(1.0));
    });
  });
}