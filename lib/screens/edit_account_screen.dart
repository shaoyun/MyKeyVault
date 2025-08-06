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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _issuerController = TextEditingController(text: widget.account.issuer);
    _nameController = TextEditingController(text: widget.account.name);
    _secretController = TextEditingController(text: widget.account.secret);
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