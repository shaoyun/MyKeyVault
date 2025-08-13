import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mykeyvault/models/models.dart';

class AuthFeedback {
  /// 显示认证错误信息
  static void showError(BuildContext context, AuthError error, {String? customMessage}) {
    final message = customMessage ?? error.message;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: '关闭',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
    
    // 触发震动反馈
    HapticFeedback.mediumImpact();
  }

  /// 显示认证成功信息
  static void showSuccess(BuildContext context, {String? message}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              message ?? '认证成功',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
    
    // 触发成功震动反馈
    HapticFeedback.lightImpact();
  }

  /// 显示锁定状态信息
  static void showLockout(BuildContext context, Duration remaining) {
    final seconds = remaining.inSeconds;
    final message = '账户已锁定，请等待 $seconds 秒后重试';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.timer,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: Duration(seconds: seconds.clamp(3, 10)),
        behavior: SnackBarBehavior.floating,
      ),
    );
    
    // 触发警告震动反馈
    HapticFeedback.heavyImpact();
  }

  /// 显示信息提示
  static void showInfo(BuildContext context, String message, {IconData? icon}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              icon ?? Icons.info_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 显示警告信息
  static void showWarning(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.warning_outlined,
              color: Colors.black,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
    
    // 触发警告震动反馈
    HapticFeedback.mediumImpact();
  }

  /// 显示确认对话框
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = '确定',
    String cancelText = '取消',
    bool isDangerous = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: isDangerous
                ? TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  )
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }

  /// 显示加载对话框
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(message),
            ],
          ],
        ),
      ),
    );
  }

  /// 隐藏加载对话框
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// 显示生物识别设置引导
  static void showBiometricSetupGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('设置生物识别'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('要使用生物识别认证，请按以下步骤设置：'),
              SizedBox(height: 16),
              Text('1. 打开设备的"设置"应用'),
              Text('2. 找到"安全"或"生物识别"选项'),
              Text('3. 设置指纹或面部识别'),
              Text('4. 返回MyKeyVault重新尝试'),
              SizedBox(height: 16),
              Text(
                '注意：不同设备的设置路径可能略有不同',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('我知道了'),
          ),
        ],
      ),
    );
  }

  /// 显示密码强度提示
  static void showPasswordStrengthTip(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('密码设置提示'),
        content: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('为了您的账户安全，请设置一个6位数字密码：'),
            SizedBox(height: 16),
            Text('• 使用不易被猜测的数字组合'),
            Text('• 避免使用生日、电话号码等个人信息'),
            Text('• 定期更换密码'),
            Text('• 不要与他人分享密码'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('我知道了'),
          ),
        ],
      ),
    );
  }

  /// 触发震动反馈
  static void vibrate({VibrationPattern pattern = VibrationPattern.medium}) {
    switch (pattern) {
      case VibrationPattern.light:
        HapticFeedback.lightImpact();
        break;
      case VibrationPattern.medium:
        HapticFeedback.mediumImpact();
        break;
      case VibrationPattern.heavy:
        HapticFeedback.heavyImpact();
        break;
      case VibrationPattern.selection:
        HapticFeedback.selectionClick();
        break;
    }
  }
}

/// 震动模式枚举
enum VibrationPattern {
  light,
  medium,
  heavy,
  selection,
}

/// 认证反馈扩展
extension AuthErrorFeedback on AuthError {
  /// 获取用户友好的错误描述
  String get userFriendlyMessage {
    switch (this) {
      case AuthError.biometricNotAvailable:
        return '您的设备不支持生物识别功能，请使用密码认证';
      case AuthError.biometricNotEnrolled:
        return '请先在系统设置中设置指纹或面部识别';
      case AuthError.biometricLockout:
        return '生物识别已被暂时锁定，请稍后再试或使用密码';
      case AuthError.passwordIncorrect:
        return '密码错误，请重新输入';
      case AuthError.tooManyAttempts:
        return '尝试次数过多，账户已被暂时锁定';
      case AuthError.systemError:
        return '系统错误，请重试或联系技术支持';
    }
  }

  /// 获取建议的解决方案
  String get suggestion {
    switch (this) {
      case AuthError.biometricNotAvailable:
        return '建议设置密码认证作为备用方案';
      case AuthError.biometricNotEnrolled:
        return '前往设置 > 安全 > 生物识别进行设置';
      case AuthError.biometricLockout:
        return '等待几分钟后重试，或使用密码认证';
      case AuthError.passwordIncorrect:
        return '确认密码是否正确，注意大小写';
      case AuthError.tooManyAttempts:
        return '请等待锁定时间结束后再试';
      case AuthError.systemError:
        return '重启应用或检查设备设置';
    }
  }

  /// 获取对应的图标
  IconData get icon {
    switch (this) {
      case AuthError.biometricNotAvailable:
      case AuthError.biometricNotEnrolled:
        return Icons.fingerprint_outlined;
      case AuthError.biometricLockout:
        return Icons.lock_clock;
      case AuthError.passwordIncorrect:
        return Icons.password;
      case AuthError.tooManyAttempts:
        return Icons.block;
      case AuthError.systemError:
        return Icons.error_outline;
    }
  }
}