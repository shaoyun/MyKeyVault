import 'package:flutter/material.dart';
import 'package:mykeyvault/models/totp_account.dart';
import 'package:mykeyvault/providers/account_provider.dart';
import 'package:provider/provider.dart';

class EditAccountScreen extends StatefulWidget {
  final TotpAccount account;

  const EditAccountScreen({super.key, required this.account});

  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _issuerController;
  late TextEditingController _nameController;
  late TextEditingController _secretController;
  late String _selectedColorType;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _issuerController = TextEditingController(text: widget.account.issuer);
    _nameController = TextEditingController(text: widget.account.name);
    _secretController = TextEditingController(text: widget.account.secret);
    _selectedColorType = widget.account.colorType;
  }

  @override
  void dispose() {
    _issuerController.dispose();
    _nameController.dispose();
    _secretController.dispose();
    super.dispose();
  }

  Future<void> _updateAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedAccount = TotpAccount(
        id: widget.account.id, // 保持原有ID
        issuer: _issuerController.text.trim(),
        name: _nameController.text.trim(),
        secret: _secretController.text.trim().replaceAll(' ', '').toUpperCase(),
        colorType: _selectedColorType,
      );

      await Provider.of<AccountProvider>(context, listen: false)
          .updateAccount(widget.account, updatedAccount);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('账户更新成功！'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('更新失败：$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String? _validateSecret(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '请输入密钥';
    }
    
    final cleanSecret = value.trim().replaceAll(' ', '').toUpperCase();
    if (cleanSecret.length < 16) {
      return '密钥长度至少16位';
    }
    
    // 检查是否为有效的Base32字符
    final base32Pattern = RegExp(r'^[A-Z2-7]+$');
    if (!base32Pattern.hasMatch(cleanSecret)) {
      return '密钥只能包含A-Z和2-7字符';
    }
    
    return null;
  }

  // 获取颜色值
  Color _getColorValue(String colorType) {
    switch (colorType) {
      case 'pink': return const Color(0xFFEC407A);
      case 'crimson': return const Color(0xFFE91E63);
      case 'purple': return const Color(0xFF9C27B0);
      case 'violet': return const Color(0xFF673AB7);
      case 'deepPurple': return const Color(0xFF512DA8);
      case 'indigo': return const Color(0xFF3F51B5);
      case 'blue': return const Color(0xFF2196F3);
      case 'lightBlue': return const Color(0xFF03A9F4);
      case 'cyan': return const Color(0xFF00BCD4);
      case 'teal': return const Color(0xFF009688);
      case 'green': return const Color(0xFF4CAF50);
      case 'lightGreen': return const Color(0xFF8BC34A);
      case 'lime': return const Color(0xFFCDDC39);
      case 'grey': return const Color(0xFF9E9E9E);
      case 'yellow': return const Color(0xFFFFC107);
      case 'amber': return const Color(0xFFFF9800);
      case 'orange': return const Color(0xFFFF5722);
      case 'deepOrange': return const Color(0xFFE65100);
      case 'red': return const Color(0xFFf44336);
      case 'deepRed': return const Color(0xFFD32F2F);
      case 'brown': return const Color(0xFF795548);
      case 'blueGrey': return const Color(0xFF607D8B);
      case 'darkGrey': return const Color(0xFF424242);
      default: return const Color(0xFF2196F3);
    }
  }

  // 获取颜色名称
  String _getColorName(String colorType) {
    switch (colorType) {
      case 'pink': return '粉红';
      case 'crimson': return '品红';
      case 'purple': return '紫红';
      case 'violet': return '紫色';
      case 'deepPurple': return '深紫';
      case 'indigo': return '靛蓝';
      case 'blue': return '蓝色';
      case 'lightBlue': return '浅蓝';
      case 'cyan': return '青色';
      case 'teal': return '水青';
      case 'green': return '森绿';
      case 'lightGreen': return '绿色';
      case 'lime': return '浅绿';
      case 'grey': return '石灰';
      case 'yellow': return '黄色';
      case 'amber': return '琥珀';
      case 'orange': return '橙黄';
      case 'deepOrange': return '橙色';
      case 'red': return '红色';
      case 'deepRed': return '深红';
      case 'brown': return '棕色';
      case 'blueGrey': return '灰色';
      case 'darkGrey': return '蓝灰';
      default: return '深灰';
    }
  }

  // 显示颜色选择对话框
  void _showColorPicker() {
    final colors = [
      'default', 'pink', 'crimson', 'purple', 'violet', 'deepPurple',
      'indigo', 'blue', 'lightBlue', 'cyan', 'teal', 'green',
      'lightGreen', 'lime', 'grey', 'yellow', 'amber', 'orange',
      'deepOrange', 'red', 'deepRed', 'brown', 'blueGrey', 'darkGrey'
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择颜色'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: colors.length,
            itemBuilder: (context, index) {
              final colorType = colors[index];
              final color = _getColorValue(colorType);
              final isSelected = _selectedColorType == colorType;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColorType = colorType;
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected 
                        ? Border.all(color: Colors.white, width: 3)
                        : null,
                    boxShadow: isSelected 
                        ? [BoxShadow(
                            color: color.withValues(alpha: 0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          )]
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 24)
                      : null,
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑账户'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _updateAccount,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    '保存',
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '账户信息',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _issuerController,
                        decoration: const InputDecoration(
                          labelText: '发行方',
                          hintText: '例如：Google, Microsoft, GitHub',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.business),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '请输入发行方';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: '账户名',
                          hintText: '例如：your.email@example.com',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '请输入账户名';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _secretController,
                        decoration: const InputDecoration(
                          labelText: '密钥',
                          hintText: '输入16位或更长的Base32密钥',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.key),
                          helperText: '密钥通常由字母A-Z和数字2-7组成',
                        ),
                        validator: _validateSecret,
                        textCapitalization: TextCapitalization.characters,
                        onChanged: (value) {
                          // 自动移除空格并转大写
                          final cleanValue = value.replaceAll(' ', '').toUpperCase();
                          if (cleanValue != value) {
                            _secretController.value = _secretController.value.copyWith(
                              text: cleanValue,
                              selection: TextSelection.collapsed(offset: cleanValue.length),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      // 颜色选择器
                      GestureDetector(
                        onTap: _showColorPicker,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.palette, color: Colors.grey),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '颜色主题',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: _getColorValue(_selectedColorType),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _getColorName(_selectedColorType),
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, 
                                  color: Colors.grey, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                color: Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange.shade700),
                          const SizedBox(width: 8),
                          Text(
                            '注意事项',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '• 修改密钥后，生成的验证码将发生变化\n'
                        '• 请确保密钥与服务提供方一致\n'
                        '• 建议在修改前备份当前配置',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _updateAccount,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: _isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Text('保存中...'),
                        ],
                      )
                    : const Text('保存更改'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}