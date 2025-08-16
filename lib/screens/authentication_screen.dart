import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mykeyvault/models/models.dart';
import 'package:mykeyvault/providers/auth_provider.dart';
import 'package:mykeyvault/widgets/biometric_auth_widget.dart';
import 'package:mykeyvault/widgets/password_auth_widget.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({Key? key}) : super(key: key);

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  AuthMethod _currentAuthMethod = AuthMethod.none;
  bool _isInitialized = false;
  Timer? _countdownTimer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _initializeAuth();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _initializeAuth() async {
    final authProvider = context.read<AuthProvider>();
    
    // 等待AuthProvider初始化完成
    if (!_isInitialized) {
      await authProvider.initialize();
      _isInitialized = true;
    }
    
    // 获取推荐的认证方法
    final recommendedMethod = await authProvider.getRecommendedAuthMethod();
    
    setState(() {
      _currentAuthMethod = recommendedMethod;
    });
    
    // 启动动画
    _fadeController.forward();
    _slideController.forward();
  }

  void _switchAuthMethod(AuthMethod method) {
    if (_currentAuthMethod == method) return;
    
    setState(() {
      _currentAuthMethod = method;
    });
    
    // 重新播放切换动画
    _slideController.reset();
    _slideController.forward();
  }

  void _onAuthSuccess() {
    // 认证成功，导航到主界面
    Navigator.of(context).pushReplacementNamed('/home');
  }

  void _onAuthError() {
    // 认证失败，可以显示错误提示或震动反馈
    // 错误信息已经在AuthProvider中处理
  }

  void _startCountdownTimer(Duration duration) {
    _countdownTimer?.cancel();
    _remainingSeconds = duration.inSeconds;
    
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingSeconds--;
      });
      
      if (_remainingSeconds <= 0) {
        timer.cancel();
        // 锁定时间结束，重新检查状态
        _initializeAuth();
      }
    });
  }

  void _stopCountdownTimer() {
    _countdownTimer?.cancel();
    _remainingSeconds = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final theme = Theme.of(context);
          
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.1),
                  theme.colorScheme.surface,
                ],
              ),
            ),
            child: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // 应用标题区域
                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          // 应用图标
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.security,
                              size: 40,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // 应用名称
                          Text(
                            'MyKeyVault',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // 副标题
                          Text(
                            '安全的TOTP认证器',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // 认证区域
                    Expanded(
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildAuthContent(authProvider),
                      ),
                    ),
                    
                    // 底部信息
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        '请验证您的身份以继续使用应用',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAuthContent(AuthProvider authProvider) {
    // 如果没有启用任何认证方式，显示设置提示
    if (!authProvider.hasAnyAuthEnabled) {
      return _buildSetupPrompt();
    }

    // 如果账户被锁定，显示锁定信息
    if (authProvider.isLocked) {
      return _buildLockedContent(authProvider);
    }

    // 根据当前认证方法显示相应的认证界面
    switch (_currentAuthMethod) {
      case AuthMethod.biometric:
        return BiometricAuthWidget(
          onSuccess: _onAuthSuccess,
          onError: _onAuthError,
          onSwitchToPassword: authProvider.canUsePassword 
              ? () => _switchAuthMethod(AuthMethod.password)
              : null,
        );
      
      case AuthMethod.password:
        return PasswordAuthWidget(
          onSuccess: _onAuthSuccess,
          onError: _onAuthError,
          onSwitchToBiometric: authProvider.canUseBiometric 
              ? () => _switchAuthMethod(AuthMethod.biometric)
              : null,
        );
      
      default:
        return _buildNoAuthAvailable();
    }
  }

  Widget _buildSetupPrompt() {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.settings_suggest,
              size: 80,
              color: theme.colorScheme.primary.withOpacity(0.7),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              '首次使用',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              '欢迎使用MyKeyVault！\n让我们为您设置安全认证',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            ElevatedButton.icon(
              onPressed: () {
                // 导航到引导页面
                Navigator.of(context).pushReplacementNamed('/onboarding');
              },
              icon: const Icon(Icons.start),
              label: const Text('开始设置'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            TextButton(
              onPressed: () {
                // 跳过认证，直接进入应用
                _onAuthSuccess();
              },
              child: const Text('暂时跳过'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockedContent(AuthProvider authProvider) {
    final theme = Theme.of(context);
    final lockoutRemaining = authProvider.lockoutRemaining;
    
    // 启动倒计时定时器
    if (lockoutRemaining != null && _countdownTimer == null) {
      _startCountdownTimer(lockoutRemaining);
    }
    
    // 使用动态倒计时或者静态剩余时间
    final displaySeconds = _remainingSeconds > 0 ? _remainingSeconds : (lockoutRemaining?.inSeconds ?? 0);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_clock,
              size: 80,
              color: theme.colorScheme.error,
            ),
            
            const SizedBox(height: 24),
            
            Text(
              '账户已锁定',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.error,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              displaySeconds > 0
                  ? '由于多次认证失败，账户已被锁定\n请等待 $displaySeconds 秒后重试'
                  : '由于多次认证失败，账户已被锁定\n请稍后重试',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            
            if (displaySeconds > 0) ...[
              const SizedBox(height: 24),
              
              // 倒计时显示
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$displaySeconds',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNoAuthAvailable() {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: theme.colorScheme.error.withOpacity(0.7),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              '认证不可用',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              '当前没有可用的认证方式\n请检查设备设置或联系管理员',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            ElevatedButton.icon(
              onPressed: () {
                // 重新初始化认证
                _initializeAuth();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }
}