import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mykeyvault/models/models.dart';
import 'package:mykeyvault/providers/auth_provider.dart';
import 'package:mykeyvault/widgets/auth_config_widget.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        elevation: 0,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // 认证设置区域
              _buildSectionHeader(context, '安全认证'),
              const SizedBox(height: 8),
              const AuthConfigWidget(),
              
              const SizedBox(height: 32),
              
              // 应用设置区域
              _buildSectionHeader(context, '应用设置'),
              const SizedBox(height: 8),
              _buildAppSettingsCard(context, authProvider),
              
              const SizedBox(height: 32),
              
              // 关于区域
              _buildSectionHeader(context, '关于'),
              const SizedBox(height: 8),
              _buildAboutCard(context),
              
              const SizedBox(height: 32),
              
              // 危险操作区域
              _buildSectionHeader(context, '数据管理'),
              const SizedBox(height: 8),
              _buildDangerZoneCard(context, authProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildAppSettingsCard(BuildContext context, AuthProvider authProvider) {
    final theme = Theme.of(context);
    
    return Card(
      child: Column(
        children: [
          // 主题设置
          ListTile(
            leading: Icon(
              Icons.palette,
              color: theme.colorScheme.primary,
            ),
            title: const Text('主题模式'),
            subtitle: Text(_getThemeModeText(authProvider.config.themeMode)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemeDialog(context, authProvider),
          ),
          
          const Divider(height: 1),
          
          // 语言设置（预留）
          ListTile(
            leading: Icon(
              Icons.language,
              color: theme.colorScheme.primary,
            ),
            title: const Text('语言'),
            subtitle: const Text('简体中文'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: 实现语言设置
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('语言设置功能即将推出')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.info,
              color: theme.colorScheme.primary,
            ),
            title: const Text('版本信息'),
            subtitle: const Text('MyKeyVault v1.0.0'),
            onTap: () => _showAboutDialog(context),
          ),
          
          const Divider(height: 1),
          
          ListTile(
            leading: Icon(
              Icons.help,
              color: theme.colorScheme.primary,
            ),
            title: const Text('帮助与支持'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showHelpDialog(context),
          ),
          
          const Divider(height: 1),
          
          ListTile(
            leading: Icon(
              Icons.privacy_tip,
              color: theme.colorScheme.primary,
            ),
            title: const Text('隐私政策'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showPrivacyDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZoneCard(BuildContext context, AuthProvider authProvider) {
    final theme = Theme.of(context);
    
    return Card(
      color: theme.colorScheme.errorContainer.withOpacity(0.3),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.warning,
              color: theme.colorScheme.error,
            ),
            title: Text(
              '重置认证设置',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            subtitle: const Text('清除所有认证配置和密码'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showResetAuthDialog(context, authProvider),
          ),
        ],
      ),
    );
  }

  String _getThemeModeText(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return '浅色模式';
      case ThemeMode.dark:
        return '深色模式';
      case ThemeMode.system:
        return '跟随系统';
    }
  }

  void _showThemeDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择主题'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('浅色模式'),
              value: ThemeMode.light,
              groupValue: authProvider.config.themeMode,
              onChanged: (value) {
                if (value != null) {
                  authProvider.updateThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('深色模式'),
              value: ThemeMode.dark,
              groupValue: authProvider.config.themeMode,
              onChanged: (value) {
                if (value != null) {
                  authProvider.updateThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('跟随系统'),
              value: ThemeMode.system,
              groupValue: authProvider.config.themeMode,
              onChanged: (value) {
                if (value != null) {
                  authProvider.updateThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'MyKeyVault',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          Icons.security,
          size: 32,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      children: [
        const Text('MyKeyVault是一个安全的TOTP认证器应用，帮助您管理和生成两步验证码。'),
        const SizedBox(height: 16),
        const Text('特性：'),
        const Text('• 生物识别认证保护'),
        const Text('• 密码备用认证'),
        const Text('• 安全的本地存储'),
        const Text('• 简洁的用户界面'),
      ],
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('帮助与支持'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '如何使用MyKeyVault：',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('1. 扫描QR码或手动输入密钥添加账户'),
              Text('2. 在设置中配置生物识别或密码认证'),
              Text('3. 使用生成的验证码进行两步验证'),
              SizedBox(height: 16),
              Text(
                '常见问题：',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Q: 如何备份我的账户？'),
              Text('A: 使用导出功能将账户数据保存到安全位置'),
              SizedBox(height: 8),
              Text('Q: 忘记认证密码怎么办？'),
              Text('A: 可以在设置中重置认证设置，但需要重新配置'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('隐私政策'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '数据收集：',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• MyKeyVault不会收集任何个人信息'),
              Text('• 所有数据都存储在您的设备本地'),
              Text('• 不会向第三方服务器发送任何数据'),
              SizedBox(height: 16),
              Text(
                '数据安全：',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• 使用行业标准加密算法保护数据'),
              Text('• 生物识别数据由系统安全管理'),
              Text('• 密码使用安全哈希算法存储'),
              SizedBox(height: 16),
              Text(
                '权限使用：',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• 相机权限：用于扫描QR码'),
              Text('• 生物识别权限：用于身份验证'),
              Text('• 存储权限：用于导入导出数据'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showResetAuthDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重置认证设置'),
        content: const Text(
          '此操作将清除所有认证配置和密码，您将需要重新设置认证方式。\n\n此操作不可撤销，确定要继续吗？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              try {
                await authProvider.clearAllAuthData();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('认证设置已重置'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('重置失败: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('确定重置'),
          ),
        ],
      ),
    );
  }
}