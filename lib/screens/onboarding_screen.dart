import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mykeyvault/models/models.dart';
import 'package:mykeyvault/providers/auth_provider.dart';
import 'package:mykeyvault/utils/auth_utils.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isSettingUp = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _skipOnboarding() async {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  Future<void> _setupBiometric() async {
    setState(() {
      _isSettingUp = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.enableBiometric();
      
      if (mounted) {
        AuthFeedback.showSuccess(context, message: '生物识别认证已启用');
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        AuthFeedback.showError(
          context, 
          AuthError.systemError,
          customMessage: '启用生物识别失败，您可以稍后在设置中配置',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSettingUp = false;
        });
      }
    }
  }

  Future<void> _setupPassword() async {
    final result = await _showPasswordSetupDialog();
    if (result != null && result.isNotEmpty) {
      setState(() {
        _isSettingUp = true;
      });

      try {
        final authProvider = context.read<AuthProvider>();
        await authProvider.setPassword(result);
        
        if (mounted) {
          AuthFeedback.showSuccess(context, message: '密码认证已设置');
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } catch (e) {
        if (mounted) {
          AuthFeedback.showError(
            context, 
            AuthError.systemError,
            customMessage: '设置密码失败，请重试',
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSettingUp = false;
          });
        }
      }
    }
  }

  Future<String?> _showPasswordSetupDialog() async {
    final TextEditingController controller = TextEditingController();
    String? result;

    await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('设置密码'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('请设置一个6位数字密码来保护您的TOTP密钥：'),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                maxLength: 6,
                obscureText: true,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  letterSpacing: 8,
                ),
                decoration: const InputDecoration(
                  hintText: '••••••',
                  counterText: '',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: controller.text.length == 6
                  ? () {
                      result = controller.text;
                      Navigator.of(context).pop(result);
                    }
                  : null,
              child: const Text('设置'),
            ),
          ],
        ),
      ),
    );

    controller.dispose();
    return result;
  }

  @override
  Widget build(BuildContext context) {
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
        child: SafeArea(
          child: Column(
            children: [
              // 顶部导航
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentPage > 0)
                      TextButton(
                        onPressed: _previousPage,
                        child: const Text('上一步'),
                      )
                    else
                      const SizedBox(width: 60),
                    
                    // 页面指示器
                    Row(
                      children: List.generate(3, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index == _currentPage
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outline,
                          ),
                        );
                      }),
                    ),
                    
                    TextButton(
                      onPressed: _skipOnboarding,
                      child: const Text('跳过'),
                    ),
                  ],
                ),
              ),
              
              // 页面内容
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  children: [
                    _buildWelcomePage(),
                    _buildSecurityPage(),
                    _buildSetupPage(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - 
                       MediaQuery.of(context).padding.top - 
                       MediaQuery.of(context).padding.bottom - 48,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 应用图标
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  Icons.security,
                  size: 50,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
              
              const SizedBox(height: 24),
              
              Text(
                '欢迎使用 MyKeyVault',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 12),
              
              Text(
                '安全的TOTP认证器，保护您的数字身份',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // 功能特点
              Column(
                children: [
                  _buildFeatureItem(
                    Icons.fingerprint,
                    '生物识别保护',
                    '使用指纹或面部识别快速安全地访问',
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureItem(
                    Icons.lock,
                    '密码备用认证',
                    '设置数字密码作为备用认证方式',
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureItem(
                    Icons.security,
                    '本地安全存储',
                    '所有数据都安全地存储在您的设备上',
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
          
              ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                ),
                child: const Text('开始使用'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityPage() {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - 
                       MediaQuery.of(context).padding.top - 
                       MediaQuery.of(context).padding.bottom - 48,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shield,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              
              const SizedBox(height: 24),
              
              Text(
                '保护您的账户',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 12),
              
              Text(
                'MyKeyVault 使用多层安全保护来确保您的TOTP密钥安全',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
          
              // 安全特性
              Column(
                children: [
                  _buildSecurityFeature(
                    Icons.lock,
                    '端到端加密',
                    '使用行业标准加密算法保护您的数据',
                  ),
                  const SizedBox(height: 24),
                  _buildSecurityFeature(
                    Icons.phone_android,
                    '本地存储',
                    '数据仅存储在您的设备上，不会上传到云端',
                  ),
                  const SizedBox(height: 24),
                  _buildSecurityFeature(
                    Icons.timer,
                    '会话超时',
                    '自动锁定功能确保长时间不使用时的安全',
                  ),
                ],
              ),
              
              const SizedBox(height: 48),
              
              ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                ),
                child: const Text('了解了'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSetupPage() {
    final theme = Theme.of(context);
    
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final biometricCapability = authProvider.biometricCapability;
        
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 
                           MediaQuery.of(context).padding.top - 
                           MediaQuery.of(context).padding.bottom - 48,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.settings,
                    size: 80,
                    color: theme.colorScheme.primary,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Text(
                    '设置认证方式',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Text(
                    '选择一种认证方式来保护您的TOTP密钥',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 32),
              
                  // 认证选项
                  if (biometricCapability.isUsable) ...[
                    _buildAuthOption(
                      icon: biometricCapability.hasFingerprint 
                          ? Icons.fingerprint 
                          : Icons.face,
                      title: '${biometricCapability.primaryBiometricName}认证',
                      subtitle: '快速安全的生物识别认证',
                      onTap: _isSettingUp ? null : _setupBiometric,
                      recommended: true,
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  _buildAuthOption(
                    icon: Icons.lock,
                    title: '密码认证',
                    subtitle: '设置6位数字密码',
                    onTap: _isSettingUp ? null : _setupPassword,
                    recommended: !biometricCapability.isUsable,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  if (_isSettingUp) ...[
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      '正在设置...',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ] else ...[
                    TextButton(
                      onPressed: _skipOnboarding,
                      child: const Text('暂时跳过，稍后设置'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityFeature(IconData icon, String title, String subtitle) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    bool recommended = false,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: recommended 
              ? theme.colorScheme.primary 
              : theme.colorScheme.outline,
          width: recommended ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 32,
        ),
        title: Row(
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (recommended) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '推荐',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}