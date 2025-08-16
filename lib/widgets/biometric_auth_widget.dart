import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mykeyvault/models/models.dart';
import 'package:mykeyvault/providers/auth_provider.dart';

class BiometricAuthWidget extends StatefulWidget {
  final VoidCallback? onSuccess;
  final VoidCallback? onError;
  final VoidCallback? onSwitchToPassword;

  const BiometricAuthWidget({
    Key? key,
    this.onSuccess,
    this.onError,
    this.onSwitchToPassword,
  }) : super(key: key);

  @override
  State<BiometricAuthWidget> createState() => _BiometricAuthWidgetState();
}

class _BiometricAuthWidgetState extends State<BiometricAuthWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // 自动开始认证动画
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
    });

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.authenticateWithBiometric();

    setState(() {
      _isAuthenticating = false;
    });

    if (success) {
      _animationController.stop();
      widget.onSuccess?.call();
    } else {
      widget.onError?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final capability = authProvider.biometricCapability;
        final theme = Theme.of(context);
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            // 生物识别图标
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      border: Border.all(
                        color: theme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      _getBiometricIcon(capability),
                      size: 60,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 32),
            
            // 标题
            Text(
              '生物识别认证',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 提示文本
            Text(
              _getPromptText(capability, authProvider.lastError),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: authProvider.lastError != null 
                    ? theme.colorScheme.error 
                    : theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // 认证按钮
            if (!_isAuthenticating) ...[
              ElevatedButton.icon(
                onPressed: capability.isUsable ? _authenticate : null,
                icon: Icon(_getBiometricIcon(capability)),
                label: Text('使用${capability.primaryBiometricName}'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 切换到密码认证
              if (widget.onSwitchToPassword != null && authProvider.canUsePassword)
                TextButton.icon(
                  onPressed: widget.onSwitchToPassword,
                  icon: const Icon(Icons.password),
                  label: const Text('使用密码'),
                ),
            ] else ...[
              // 认证中的加载指示器
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                '正在验证...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
            
            // 错误信息
            if (authProvider.lastError != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        authProvider.errorMessage ?? '认证失败',
                        style: TextStyle(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // 设备不支持时的提示
            if (!capability.isDeviceSupported) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '您的设备不支持生物识别认证',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getBiometricIcon(BiometricCapability capability) {
    if (capability.hasFingerprint) {
      return Icons.fingerprint;
    } else if (capability.hasFace) {
      return Icons.face;
    } else {
      return Icons.security;
    }
  }

  String _getPromptText(BiometricCapability capability, AuthError? error) {
    if (error != null) {
      switch (error) {
        case AuthError.biometricNotAvailable:
          return '生物识别功能不可用';
        case AuthError.biometricNotEnrolled:
          return '请先在系统设置中设置生物识别';
        case AuthError.biometricLockout:
          return '生物识别已被锁定，请稍后再试';
        case AuthError.tooManyAttempts:
          return '尝试次数过多，请稍后再试';
        default:
          return '认证失败，请重试';
      }
    }

    if (!capability.isDeviceSupported) {
      return '设备不支持生物识别';
    }

    if (!capability.isAvailable) {
      return '生物识别功能不可用';
    }

    if (capability.availableTypes.isEmpty) {
      return '请先在系统设置中设置生物识别';
    }

    return '请验证您的${capability.primaryBiometricName}以继续';
  }
}