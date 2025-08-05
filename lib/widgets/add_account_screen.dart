import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/models/totp_account.dart';
import 'package:myapp/providers/account_provider.dart';
import 'package:base32/base32.dart';

class AddAccountScreen extends StatefulWidget {
  final TotpAccount? initialAccount; // 用于从二维码扫描传递数据

  const AddAccountScreen({super.key, this.initialAccount});

  @override
  _AddAccountScreenState createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _issuerController = TextEditingController();
  final _accountNameController = TextEditingController();
  final _secretController = TextEditingController();
  final _digitsController = TextEditingController(text: '6');
  final _periodController = TextEditingController(text: '30');
  String _selectedAlgorithm = 'SHA1'; // Default algorithm

  @override
  void initState() {
    super.initState();
    // 如果有初始账户数据，则填充到表单
    if (widget.initialAccount != null) {
      _issuerController.text = widget.initialAccount!.issuer;
      _accountNameController.text = widget.initialAccount!.accountName;
      _secretController.text = widget.initialAccount!.secret;
      _digitsController.text = widget.initialAccount!.digits.toString();
      _periodController.text = widget.initialAccount!.period.toString();
      _selectedAlgorithm = widget.initialAccount!.algorithm;
    }
  }

  @override
  void dispose() {
    _issuerController.dispose();
    _accountNameController.dispose();
    _secretController.dispose();
    _digitsController.dispose();
    _periodController.dispose();
    super.dispose();
  }

  void _addAccount() {
    if (_formKey.currentState!.validate()) {
      // 验证密钥是否为有效的 Base32 编码
      try {
        base32.decode(_secretController.text.trim());
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('密钥不是有效的 Base32 编码')));
        return; // 停止添加账户
      }

      final newAccount = TotpAccount(
        issuer: _issuerController.text.trim(),
        accountName: _accountNameController.text.trim(),
        secret: _secretController.text.trim(),
        digits: int.parse(_digitsController.text),
        period: int.parse(_periodController.text),
        algorithm: _selectedAlgorithm,
      );

      Provider.of<AccountProvider>(
        context,
        listen: false,
      ).addAccount(newAccount);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('手动添加账户')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _issuerController,
                decoration: const InputDecoration(
                  labelText: '发行商 (例如: Google)',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入发行商';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12.0),
              TextFormField(
                controller: _accountNameController,
                decoration: const InputDecoration(
                  labelText: '账户名 (例如: 用户名或邮箱)',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入账户名';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12.0),
              TextFormField(
                controller: _secretController,
                decoration: const InputDecoration(labelText: '密钥 (Secret Key)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入密钥';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12.0),
              TextFormField(
                controller: _digitsController,
                decoration: const InputDecoration(labelText: '位数 (默认为 6)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入位数';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return '请输入有效的正整数位数';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12.0),
              TextFormField(
                controller: _periodController,
                decoration: const InputDecoration(
                  labelText: '时间步长 (秒, 默认为 30)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入时间步长';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return '请输入有效的正整数时间步长';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12.0),
              DropdownButtonFormField<String>(
                value: _selectedAlgorithm,
                decoration: const InputDecoration(labelText: '算法'),
                items:
                    <String>[
                      'SHA1',
                      'SHA256',
                      'SHA512',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedAlgorithm = newValue;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请选择算法';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _addAccount,
                child: const Text('添加账户'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
