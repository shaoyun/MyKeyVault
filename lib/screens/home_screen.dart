import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mykeyvault/models/totp_account.dart';
import 'package:mykeyvault/providers/account_provider.dart';
import 'package:mykeyvault/screens/qr_scanner_screen.dart';
import 'package:mykeyvault/screens/manual_input_screen.dart';
import 'package:mykeyvault/widgets/account_list_item.dart';

import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TotpAccount> _filterAccounts(List<TotpAccount> accounts) {
    if (_searchQuery.isEmpty) {
      return accounts;
    }
    
    return accounts.where((account) {
      final issuerMatch = account.issuer.toLowerCase().contains(_searchQuery.toLowerCase());
      final nameMatch = account.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return issuerMatch || nameMatch;
    }).toList();
  }

  Future<void> _importAccounts(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      
      try {
        if (kIsWeb) {
          // Web平台：直接使用文件字节数据
          if (file.bytes != null) {
            await Provider.of<AccountProvider>(context, listen: false)
                .importAccountsFromBytes(file.bytes!);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('账户导入成功！'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('无法读取文件内容'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          // 移动平台：使用文件路径
          if (file.path != null) {
            final ioFile = File(file.path!);
            await Provider.of<AccountProvider>(context, listen: false)
                .importAccounts(ioFile);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('账户导入成功！'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('无法访问文件路径'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('导入失败：$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportAccounts(BuildContext context) async {
    final accountProvider = Provider.of<AccountProvider>(context, listen: false);
    
    // 检查是否有账户可导出
    if (accountProvider.accounts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('暂无账户可导出，请先添加账户'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    final result = await accountProvider.exportAccounts();
    if (result != null) {
      if (kIsWeb) {
        // Web平台：显示下载成功消息
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('配置文件已下载到浏览器默认下载文件夹'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // 移动平台：使用分享功能
        await Share.shareXFiles([XFile(result)],
            text: 'TOTP Accounts Export');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('导出失败，请重试'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }



  void _showAddAccountOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '添加账户',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(
                  Icons.qr_code_scanner,
                  color: Colors.blue,
                  size: 28,
                ),
                title: const Text('扫描二维码'),
                subtitle: const Text('扫描服务提供的二维码快速添加'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const QrScannerScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.edit,
                  color: Colors.green,
                  size: 28,
                ),
                title: const Text('手动输入'),
                subtitle: const Text('手动输入账户信息和密钥'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ManualInputScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final accountProvider = Provider.of<AccountProvider>(context);
    final filteredAccounts = _filterAccounts(accountProvider.accounts);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MyKeyVault'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
            tooltip: '设置',
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).colorScheme.primary,
            ),
            onSelected: (value) {
              if (value == 'import') {
                _importAccounts(context);
              } else if (value == 'export') {
                _exportAccounts(context);
              } else if (value == 'scan_qr') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QrScannerScreen(),
                  ),
                );
              } else if (value == 'manual_input') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ManualInputScreen(),
                  ),
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'scan_qr',
                child: Row(
                  children: [
                    Icon(Icons.qr_code_scanner, color: Colors.blue),
                    SizedBox(width: 12),
                    Text('扫描二维码'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'manual_input',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.green),
                    SizedBox(width: 12),
                    Text('手动输入'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.file_download, color: Theme.of(context).colorScheme.primary),
                    SizedBox(width: 12),
                    Text('导入账户'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.file_upload, color: Theme.of(context).colorScheme.primary),
                    SizedBox(width: 12),
                    Text('导出账户'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索框
          if (accountProvider.accounts.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: '搜索',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          // 账户列表
          Expanded(
            child: accountProvider.accounts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.security,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'No accounts found.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add your first account to get started.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const QrScannerScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.qr_code_scanner),
                              label: const Text('扫描二维码'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ManualInputScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.edit),
                              label: const Text('手动输入'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : filteredAccounts.isEmpty && _searchQuery.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '未找到匹配的账户',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '尝试搜索发行方或账户名',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredAccounts.length,
                        itemBuilder: (context, index) {
                          final account = filteredAccounts[index];
                          return AccountListItem(account: account);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
