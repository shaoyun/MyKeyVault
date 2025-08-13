import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mykeyvault/models/models.dart';
import 'package:mykeyvault/providers/auth_provider.dart';

class AuthConfigWidget extends StatefulWidget {
  const AuthConfigWidget({Key? key}) : super(key: key);

  @override
  State<AuthConfigWidget> createState() => _AuthConfigWidgetState();
}

class _AuthConfigWidgetState extends State<AuthConfigWidget> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isSettingPassword = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final theme = Theme.of(context);
        
        return Card(
          child: Column(
            children: [
              // 生物识别认证设置
              _buildBiometricTile(context, authProvider, theme),
              
              const Divider(height: 1),
              
              // 密码认证设置
              _buildPasswordTile(context, authProvider, theme),
              
              const Divider(height: 1),
              
              // 认证超时设置
              _buildTimeoutTile(context, authProvider, theme),
              
              // 错误提示
              if (authProvider.lastError != null) ...[
                const Divider(height: 1),
                _buildErrorTile(context, authProvider, theme),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildBiometricTile(BuildContext context, AuthProvider authProvider, ThemeData theme) {
    final capability = authProvider.biometricCapability;
    final isEnabled = authProvider.config.biometricEnabled;
    final canEnable = capability.isUsable;
    
    return ListTile(
      leading: Icon(
        capability.hasFingerprint ? Icons.fingerprint : 
        capability.hasFace ? Icons.face : Icons.security,
        color: isEnabled ? theme.colorScheme.primary : theme.colorScheme.outline,
      ),
      title: Text('${capability.primaryBiometricName}认证'),
      subtitle: Text(_getBiometricSubtitle(capability, isEnabled)),
      trailing: Switch(
        value: isEnabled,
        onChanged: canEnable ? (value) {
          if (value) {
            authProvider.enableBiometric();
          } else {
            authProvider.disableBiometric();
          }
        } : null,
      ),
      onTap: canEnable ? () {
        if (isEnabled) {
          authProvider.disableBiometric();
        } else {
          authProvider.enableBiometric();
        }
      } : null,
    );
  }

  Widget _buildPasswordTile(BuildContext context, AuthProvider authProvider, ThemeData theme) {
    final isEnabled = authProvider.config.passwordEnabled;
    
    return ListTile(
      leading: Icon(
        Icons.lock,
        color: isEnabled ? theme.colorScheme.primary : theme.colorScheme.outline,
      ),
      title: const Text('密码认证'),
      subtitle: Text(isEnabled ? '已启用6位数字密码' : '点击设置6位数字密码'),
      trailing: isEnabled 
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showPasswordDialog(context, authProvider, true),
                  tooltip: '修改密码',
                ),
                Switch(
                  value: true,
                  onChanged: (value) {
                    if (!value) {
                      _showDisablePasswordDialog(context, authProvider);
                    }
                  },
                ),
              ],
            )
          : Switch(
              value: false,
              onChanged: (value) {
                if (value) {
                  _showPasswordDialog(context, authProvider, false);
                }
              },
            ),
      onTap: () {
        if (isEnabled) {
          _showPasswordDialog(context, authProvider, true);
        } else {
          _showPasswordDialog(context, authProvider, false);
        }
      },
    );
  }

  Widget _buildTimeoutTile(BuildContext context, AuthProvider authProvider, ThemeData theme) {
    final timeoutMinutes = authProvider.config.authTimeoutMinutes;
    
    return ListTile(
      leading: Icon(
        Icons.timer,
        color: theme.colorScheme.primary,
      ),
      title: const Text('认证有效时长'),
      subtitle: Text('$timeoutMinutes分钟后需要重新认证'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showTimeoutDialog(context, authProvider),
    );
  }

  Widget _buildErrorTile(BuildContext context, AuthProvider authProvider, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.colorScheme.errorContainer.withOpacity(0.3),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: theme.colorScheme.error,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              authProvider.errorMessage ?? '发生错误',
              style: TextStyle(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getBiometricSubtitle(BiometricCapability capability, bool isEnabled) {
    if (!capability.isDeviceSupported) {
      return '设备不支持生物识别';
    }
    
    if (!capability.isAvailable) {
      return '生物识别功能不可用';
    }
    
    if (capability.availableTypes.isEmpty) {
      return '请先在系统设置中设置生物识别';
    }
    
    if (isEnabled) {
      return '已启用，用于应用解锁';
    }
    
    return '点击启用生物识别认证';
  }

  void _showPasswordDialog(BuildContext context, AuthProvider authProvider, bool isEdit) {
    _passwordController.clear();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEdit ? '修改密码' : '设置密码'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isEdit ? '请输入新的6位数字密码' : '请设置6位数字密码',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
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
              if (_isSettingPassword) ...[
                const SizedBox(height: 16),
                const CircularProgressIndicator(),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: _isSettingPassword ? null : () {
                Navigator.of(context).pop();
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: _isSettingPassword || _passwordController.text.length != 6 
                  ? null 
                  : () async {
                setState(() {
                  _isSettingPassword = true;
                });
                
                try {
                  await authProvider.setPassword(_passwordController.text);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isEdit ? '密码已修改' : '密码已设置'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('设置失败: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } finally {
                  if (mounted) {
                    setState(() {
                      _isSettingPassword = false;
                    });
                  }
                }
              },
              child: Text(isEdit ? '修改' : '设置'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDisablePasswordDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('禁用密码认证'),
        content: const Text('确定要禁用密码认证吗？这将删除已设置的密码。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              try {
                await authProvider.disablePassword();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('密码认证已禁用'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('禁用失败: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showTimeoutDialog(BuildContext context, AuthProvider authProvider) {
    final currentTimeout = authProvider.config.authTimeoutMinutes;
    int selectedTimeout = currentTimeout;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('认证有效时长'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('选择认证后多长时间内无需重新验证：'),
              const SizedBox(height: 16),
              ...[ 5, 15, 30, 60].map((minutes) => RadioListTile<int>(
                title: Text('${minutes}分钟'),
                value: minutes,
                groupValue: selectedTimeout,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedTimeout = value;
                    });
                  }
                },
              )),
            ],
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
                  await authProvider.updateAuthTimeout(selectedTimeout);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('设置已更新'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('更新失败: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('确定'),
            ),
          ],
        ),
      ),
    );
  }
}