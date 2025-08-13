import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mykeyvault/models/models.dart';
import 'package:mykeyvault/providers/auth_provider.dart';

class PasswordAuthWidget extends StatefulWidget {
  final VoidCallback? onSuccess;
  final VoidCallback? onError;
  final VoidCallback? onSwitchToBiometric;

  const PasswordAuthWidget({
    Key? key,
    this.onSuccess,
    this.onError,
    this.onSwitchToBiometric,
  }) : super(key: key);

  @override
  State<PasswordAuthWidget> createState() => _PasswordAuthWidgetState();
}

class _PasswordAuthWidgetState extends State<PasswordAuthWidget>
    with SingleTickerProviderStateMixin {
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  
  bool _isAuthenticating = false;
  bool _obscurePassword = true;
  String _password = '';

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));

    // 自动聚焦到密码输入框
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _passwordFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating || _password.length != 6) return;

    setState(() {
      _isAuthenticating = true;
    });

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.authenticateWithPassword(_password);

    setState(() {
      _isAuthenticating = false;
    });

    if (success) {
      widget.onSuccess?.call();
    } else {
      // 密码错误时震动效果
      _shakeController.forward().then((_) {
        _shakeController.reverse();
      });
      
      // 清空密码输入
      _passwordController.clear();
      _password = '';
      
      widget.onError?.call();
    }
  }

  void _onPasswordChanged(String value) {
    setState(() {
      _password = value;
    });

    // 当输入6位数字时自动认证
    if (value.length == 6) {
      _authenticate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final theme = Theme.of(context);
        final isLocked = authProvider.isLocked;
        final lockoutRemaining = authProvider.lockoutRemaining;
        
        return AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_shakeAnimation.value, 0),
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height - 
                                 MediaQuery.of(context).padding.top - 
                                 MediaQuery.of(context).padding.bottom,
                      minWidth: double.infinity,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                  // 密码图标
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      border: Border.all(
                        color: theme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.lock,
                      size: 50,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 标题
                  Text(
                    '密码认证',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 提示文本
                  Text(
                    _getPromptText(authProvider.lastError, isLocked, lockoutRemaining),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: _getPromptColor(theme, authProvider.lastError, isLocked),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 锁定状态显示
                  if (isLocked) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.timer,
                            color: theme.colorScheme.error,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '账户已锁定',
                            style: TextStyle(
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (lockoutRemaining != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              '剩余时间: ${lockoutRemaining.inSeconds}秒',
                              style: TextStyle(
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ] else ...[
                    // 密码输入区域
                    Container(
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: Column(
                        children: [
                          // 密码输入框
                          TextField(
                            controller: _passwordController,
                            focusNode: _passwordFocusNode,
                            enabled: !_isAuthenticating,
                            obscureText: _obscurePassword,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              letterSpacing: 8,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              hintText: '输入6位密码',
                              counterText: '',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            onChanged: _onPasswordChanged,
                            onSubmitted: (_) => _authenticate(),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // 密码点指示器
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(6, (index) {
                              final isFilled = index < _password.length;
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isFilled 
                                      ? theme.colorScheme.primary 
                                      : theme.colorScheme.outline,
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 认证按钮
                    if (!_isAuthenticating) ...[
                      ElevatedButton.icon(
                        onPressed: _password.length == 6 ? _authenticate : null,
                        icon: const Icon(Icons.lock_open),
                        label: const Text('解锁'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // 切换到生物识别认证
                      if (widget.onSwitchToBiometric != null && authProvider.canUseBiometric)
                        TextButton.icon(
                          onPressed: widget.onSwitchToBiometric,
                          icon: const Icon(Icons.fingerprint),
                          label: Text('使用${authProvider.biometricCapability.primaryBiometricName}'),
                        ),
                    ] else ...[
                      // 认证中的加载指示器
                      const CircularProgressIndicator(),                      
                      const SizedBox(height: 12),
                      Text(
                        '正在验证...',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ],
                  
                  // 错误信息
                  if (authProvider.lastError != null && !isLocked) ...[
                    const SizedBox(height: 12),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  authProvider.errorMessage ?? '认证失败',
                                  style: TextStyle(
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                                if (authProvider.config.failedAttempts > 0) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    '失败次数: ${authProvider.config.failedAttempts}/3',
                                    style: TextStyle(
                                      color: theme.colorScheme.error,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
      },
    );
  }

  String _getPromptText(AuthError? error, bool isLocked, Duration? lockoutRemaining) {
    if (isLocked) {
      if (lockoutRemaining != null) {
        return '账户已锁定，请等待 ${lockoutRemaining.inSeconds} 秒';
      }
      return '账户已锁定，请稍后再试';
    }

    if (error != null) {
      switch (error) {
        case AuthError.passwordIncorrect:
          return '密码错误，请重试';
        case AuthError.tooManyAttempts:
          return '尝试次数过多，账户已锁定';
        default:
          return '认证失败，请重试';
      }
    }

    return '请输入您的6位数字密码';
  }

  Color _getPromptColor(ThemeData theme, AuthError? error, bool isLocked) {
    if (error != null || isLocked) {
      return theme.colorScheme.error;
    }
    return theme.colorScheme.onSurface.withOpacity(0.7);
  }
}