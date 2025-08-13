import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mykeyvault/models/models.dart';
import 'package:mykeyvault/providers/auth_provider.dart';
import 'package:mykeyvault/screens/authentication_screen.dart';

class AuthenticationWrapper extends StatefulWidget {
  final Widget child;
  
  const AuthenticationWrapper({
    Key? key, 
    required this.child,
  }) : super(key: key);

  @override
  State<AuthenticationWrapper> createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper>
    with WidgetsBindingObserver {
  bool _isInitialized = false;
  bool _isCheckingAuth = true;
  DateTime? _lastPauseTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeAuth();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    final authProvider = context.read<AuthProvider>();
    
    switch (state) {
      case AppLifecycleState.paused:
        // 应用进入后台，记录时间
        _handleAppPaused();
        break;
      case AppLifecycleState.resumed:
        // 应用恢复，检查是否需要重新认证
        _handleAppResumed();
        break;
      case AppLifecycleState.inactive:
        // 应用失去焦点（如来电、通知等）
        break;
      case AppLifecycleState.detached:
        // 应用即将终止
        break;
      case AppLifecycleState.hidden:
        // 应用被隐藏
        break;
    }
  }

  Future<void> _initializeAuth() async {
    if (!mounted) return;
    
    try {
      final authProvider = context.read<AuthProvider>();
      
      if (!_isInitialized) {
        await authProvider.initialize();
        _isInitialized = true;
      }
      
      // 检查认证状态
      await _checkAuthenticationStatus();
      
    } catch (e) {
      // 初始化失败，显示错误或允许访问
      debugPrint('认证初始化失败: $e');
      if (mounted) {
        setState(() {
          _isCheckingAuth = false;
        });
      }
    }
  }

  Future<void> _checkAuthenticationStatus() async {
    final authProvider = context.read<AuthProvider>();
    
    // 如果没有启用任何认证方式，直接允许访问
    if (!authProvider.hasAnyAuthEnabled) {
      if (mounted) {
        setState(() {
          _isCheckingAuth = false;
        });
      }
      return;
    }
    
    // 如果账户被锁定，需要等待解锁
    if (authProvider.isLocked) {
      if (mounted) {
        setState(() {
          _isCheckingAuth = false;
        });
      }
      return;
    }
    
    // 检查是否有有效的认证会话
    if (authProvider.config.isAuthValid && authProvider.isAuthenticated) {
      // 认证仍然有效，允许访问
      if (mounted) {
        setState(() {
          _isCheckingAuth = false;
        });
      }
    } else {
      // 需要重新认证
      if (mounted) {
        setState(() {
          _isCheckingAuth = false;
        });
      }
    }
  }

  void _handleAppPaused() {
    _lastPauseTime = DateTime.now();
  }

  void _handleAppResumed() {
    if (!mounted) return;
    
    final authProvider = context.read<AuthProvider>();
    
    // 检查应用在后台的时间
    if (_lastPauseTime != null) {
      final backgroundDuration = DateTime.now().difference(_lastPauseTime!);
      
      // 如果在后台超过5分钟，需要重新认证
      if (backgroundDuration.inMinutes >= 5) {
        authProvider.logout();
      }
    }
    
    // 如果当前已认证但会话已过期，需要重新认证
    if (authProvider.isAuthenticated && !authProvider.config.isAuthValid) {
      authProvider.logout();
    }
    
    // 重新检查认证状态
    _checkAuthenticationStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // 如果正在检查认证状态，显示加载界面
        if (_isCheckingAuth) {
          return _buildLoadingScreen();
        }
        
        // 如果没有启用任何认证方式，直接显示主界面
        if (!authProvider.hasAnyAuthEnabled) {
          return widget.child;
        }
        
        // 如果已认证且会话有效，显示主界面
        if (authProvider.isAuthenticated && authProvider.config.isAuthValid) {
          return widget.child;
        }
        
        // 否则显示认证界面
        return const AuthenticationScreen();
      },
    );
  }

  Widget _buildLoadingScreen() {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Container(
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
              
              const SizedBox(height: 32),
              
              // 应用名称
              Text(
                'MyKeyVault',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 副标题
              Text(
                '安全的TOTP认证器',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              
              const SizedBox(height: 48),
              
              // 加载指示器
              CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
              
              const SizedBox(height: 16),
              
              // 加载文本
              Text(
                '正在初始化...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}