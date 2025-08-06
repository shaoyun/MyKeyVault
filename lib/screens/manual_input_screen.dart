import 'package:flutter/material.dart';
import 'package:mykeyvault/models/totp_account.dart';
import 'package:mykeyvault/providers/account_provider.dart';
import 'package:provider/provider.dart';

class ManualInputScreen extends StatefulWidget {
  const ManualInputScreen({super.key});

  @override
  State<ManualInputScreen> createState() => _ManualInputScreenState();
}

class _ManualInputScreenState extends State<ManualInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _issuerController = TextEditingController();
  final _nameController = TextEditingController();
  final _secretController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _issuerController.dispose();
    _nameController.dispose();
    _secretController.dispose();
    super.dispose();
  }

  Future<void> _saveAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final account = TotpAccount(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        issuer: _issuerController.text.trim(),
        name: _nameController.text.trim(),
        secret: _secretController.text.trim().replaceAll(' ', '').toUpperCase(),
      );

      await Provider.of<AccountProvider>(context, listen: false)
          .addAccount(account);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('账户添加成功！'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('添加失败：$e'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('手动添加账户'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveAccount,
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Text(
                            '使用说明',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '1. 发行方：提供二步验证的服务名称\n'
                        '2. 账户名：您在该服务中的用户名或邮箱\n'
                        '3. 密钥：服务提供的Base32格式密钥\n\n'
                        '密钥通常在启用二步验证时显示，是一串由字母A-Z和数字2-7组成的字符串。',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveAccount,
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
                    : const Text('保存账户'),
              ),
              const SizedBox(height: 32), // 底部额外间距
            ],
          ),
        ),
      ),
    );
  }
}