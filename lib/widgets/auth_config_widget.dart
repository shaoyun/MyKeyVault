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
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isSettingPassword = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
        onChanged: canEnable ? (bool value) {
          if (value) {
            _enableBiometricWithPermissionCheck(context, authProvider);
          } else {
            authProvider.disableBiometric();
          }
        } : (!canEnable && !capability.isDeviceSupported) ? (_) => _showBiometricHelpDialog(context) : null,
      ),
      onTap: () {
        if (canEnable) {
          if (isEnabled) {
            authProvider.disableBiometric();
          } else {
            _enableBiometricWithPermissionCheck(context, authProvider);
          }
        } else {
          _showBiometricHelpDialog(context);
        }
      },
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
    _confirmPasswordController.clear();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final passwordsMatch = _passwordController.text == _confirmPasswordController.text;
          final canSubmit = _passwordController.text.length == 6 && 
                           _confirmPasswordController.text.length == 6 && 
                           passwordsMatch;
          
          return AlertDialog(
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
                    labelText: '密码',
                    hintText: '••••••',
                    counterText: '',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _confirmPasswordController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  obscureText: true,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    letterSpacing: 8,
                  ),
                  decoration: InputDecoration(
                    labelText: '确认密码',
                    hintText: '••••••',
                    counterText: '',
                    border: OutlineInputBorder(),
                    errorText: _confirmPasswordController.text.isNotEmpty && !passwordsMatch
                        ? '密码不匹配'
                        : null,
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
                onPressed: _isSettingPassword || !canSubmit
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
          );
        },
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

  Future<void> _enableBiometricWithPermissionCheck(BuildContext context, AuthProvider authProvider) async {
    final capability = authProvider.biometricCapability;
    
    // 检查设备支持
    if (!capability.isDeviceSupported) {
      _showBiometricUnsupportedDialog(context);
      return;
    }
    
    // 检查系统权限
    if (!capability.isAvailable) {
      _showBiometricPermissionDialog(context);
      return;
    }
    
    // 检查是否已设置生物识别
    if (capability.availableTypes.isEmpty) {
      _showBiometricSetupDialog(context);
      return;
    }
    
    // 尝试启用生物识别并进行一次验证确认
    try {
      await authProvider.enableBiometric();
      
      // 启用后立即进行一次测试验证
      final testResult = await authProvider.authenticateWithBiometric();
      if (!testResult && context.mounted) {
        // 如果测试失败，显示错误并禁用
        await authProvider.disableBiometric();
        _showBiometricTestFailedDialog(context, authProvider.errorMessage);
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('生物识别认证已启用'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('启用失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showBiometricHelpDialog(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final capability = authProvider.biometricCapability;
    
    String title;
    String content;
    List<Widget> actions = [];
    
    if (!capability.isDeviceSupported) {
      title = '设备不支持';
      content = '您的设备不支持生物识别认证功能。\n\n请使用密码认证来保护您的应用。';
      actions = [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('了解'),
        ),
      ];
    } else if (!capability.isAvailable) {
      title = '权限未授予';
      content = '应用需要生物识别权限才能启用此功能。\n\n请在系统设置中授予MyKeyVault生物识别权限。';
      actions = [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            // TODO: 打开应用设置页面
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('请在"设置 > 应用 > MyKeyVault > 权限"中授予生物识别权限'),
                duration: Duration(seconds: 5),
              ),
            );
          },
          child: const Text('去设置'),
        ),
      ];
    } else if (capability.availableTypes.isEmpty) {
      title = '未设置生物识别';
      content = '您的设备支持生物识别，但尚未设置。\n\n请先在系统设置中设置指纹或面部识别。';
      actions = [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('请在"设置 > 安全 > 生物识别"中设置指纹或面部识别'),
                duration: Duration(seconds: 5),
              ),
            );
          },
          child: const Text('去设置'),
        ),
      ];
    } else {
      title = '生物识别帮助';
      content = '如果生物识别无法正常工作，请检查：\n\n1. 权限是否已授予\n2. 指纹或面部识别是否已设置\n3. 传感器是否干净\n4. 重启应用后再试';
      actions = [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('了解'),
        ),
      ];
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.help_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(content),
        actions: actions,
      ),
    );
  }

  void _showBiometricUnsupportedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('设备不支持'),
        content: const Text('您的设备不支持生物识别认证功能。请使用密码认证来保护您的应用。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('了解'),
          ),
        ],
      ),
    );
  }

  void _showBiometricPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('需要权限'),
        content: const Text('启用生物识别认证需要相应的系统权限。\n\n请在系统设置中授予MyKeyVault生物识别权限。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('请在"设置 > 应用 > MyKeyVault > 权限"中授予生物识别权限'),
                  duration: Duration(seconds: 5),
                ),
              );
            },
            child: const Text('去设置'),
          ),
        ],
      ),
    );
  }

  void _showBiometricSetupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('请设置生物识别'),
        content: const Text('您的设备支持生物识别，但尚未设置。\n\n请先在系统设置中设置指纹或面部识别，然后再启用此功能。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('请在"设置 > 安全 > 生物识别"中设置指纹或面部识别'),
                  duration: Duration(seconds: 5),
                ),
              );
            },
            child: const Text('去设置'),
          ),
        ],
      ),
    );
  }

  void _showBiometricTestFailedDialog(BuildContext context, String? errorMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('验证失败'),
        content: Text('生物识别测试验证失败。\n\n错误信息：${errorMessage ?? "未知错误"}\n\n请检查生物识别设置是否正确。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('了解'),
          ),
        ],
      ),
    );
  }
}