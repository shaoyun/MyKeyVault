import 'dart:math';
import 'package:flutter/material.dart';

class PasswordUtils {
  /// 验证密码格式
  static bool isValidPassword(String password) {
    return password.length == 6 && RegExp(r'^\d{6}$').hasMatch(password);
  }

  /// 评估密码强度
  static PasswordStrength evaluatePasswordStrength(String password) {
    if (!isValidPassword(password)) {
      return PasswordStrength.invalid;
    }

    // 检查是否为简单的连续数字
    if (_isSequentialNumbers(password)) {
      return PasswordStrength.weak;
    }

    // 检查是否为重复数字
    if (_isRepeatingNumbers(password)) {
      return PasswordStrength.weak;
    }

    // 检查是否为常见密码
    if (_isCommonPassword(password)) {
      return PasswordStrength.weak;
    }

    // 检查数字的多样性
    final uniqueDigits = password.split('').toSet().length;
    if (uniqueDigits >= 4) {
      return PasswordStrength.strong;
    } else if (uniqueDigits >= 3) {
      return PasswordStrength.medium;
    } else {
      return PasswordStrength.weak;
    }
  }

  /// 检查是否为连续数字
  static bool _isSequentialNumbers(String password) {
    final sequences = [
      '123456', '654321', '012345', '543210',
      '234567', '765432', '345678', '876543',
      '456789', '987654', '567890', '098765',
    ];
    return sequences.contains(password);
  }

  /// 检查是否为重复数字
  static bool _isRepeatingNumbers(String password) {
    // 检查全部相同
    if (password.split('').toSet().length == 1) {
      return true;
    }

    // 检查重复模式 (如 121212, 123123)
    if (password.length == 6) {
      final first3 = password.substring(0, 3);
      final last3 = password.substring(3, 6);
      if (first3 == last3) {
        return true;
      }

      final first2 = password.substring(0, 2);
      if (password == first2 * 3) {
        return true;
      }
    }

    return false;
  }

  /// 检查是否为常见密码
  static bool _isCommonPassword(String password) {
    final commonPasswords = [
      '000000', '111111', '222222', '333333', '444444',
      '555555', '666666', '777777', '888888', '999999',
      '123456', '654321', '111222', '112233', '121212',
      '123123', '123321', '131313', '232323', '456456',
      '789789', '147258', '258147', '369258', '159753',
      '951753', '741852', '852741', '963852', '258963',
    ];
    return commonPasswords.contains(password);
  }

  /// 生成密码强度提示
  static String getPasswordStrengthTip(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.invalid:
        return '密码必须是6位数字';
      case PasswordStrength.weak:
        return '密码强度较弱，建议使用更复杂的数字组合';
      case PasswordStrength.medium:
        return '密码强度中等，可以使用';
      case PasswordStrength.strong:
        return '密码强度良好';
    }
  }

  /// 生成随机密码建议
  static List<String> generatePasswordSuggestions({int count = 3}) {
    final random = Random.secure();
    final suggestions = <String>[];

    while (suggestions.length < count) {
      final password = List.generate(6, (_) => random.nextInt(10)).join();
      
      // 确保生成的密码不是弱密码
      if (evaluatePasswordStrength(password) != PasswordStrength.weak) {
        suggestions.add(password);
      }
    }

    return suggestions;
  }

  /// 格式化密码显示（用于UI显示）
  static String formatPasswordForDisplay(String password, {bool obscure = true}) {
    if (!isValidPassword(password)) {
      return '';
    }

    if (obscure) {
      return '• ' * password.length;
    } else {
      return password.split('').join(' ');
    }
  }

  /// 验证密码输入字符
  static bool isValidPasswordCharacter(String char) {
    return RegExp(r'^\d$').hasMatch(char);
  }

  /// 清理密码输入（移除非数字字符）
  static String cleanPasswordInput(String input) {
    return input.replaceAll(RegExp(r'[^\d]'), '');
  }
}

/// 密码强度枚举
enum PasswordStrength {
  invalid,
  weak,
  medium,
  strong,
}

/// 密码强度扩展
extension PasswordStrengthExtension on PasswordStrength {
  /// 获取强度颜色
  Color get color {
    switch (this) {
      case PasswordStrength.invalid:
        return Colors.grey;
      case PasswordStrength.weak:
        return Colors.red;
      case PasswordStrength.medium:
        return Colors.orange;
      case PasswordStrength.strong:
        return Colors.green;
    }
  }

  /// 获取强度文本
  String get text {
    switch (this) {
      case PasswordStrength.invalid:
        return '无效';
      case PasswordStrength.weak:
        return '弱';
      case PasswordStrength.medium:
        return '中';
      case PasswordStrength.strong:
        return '强';
    }
  }

  /// 获取强度值（0-1）
  double get value {
    switch (this) {
      case PasswordStrength.invalid:
        return 0.0;
      case PasswordStrength.weak:
        return 0.25;
      case PasswordStrength.medium:
        return 0.6;
      case PasswordStrength.strong:
        return 1.0;
    }
  }
}