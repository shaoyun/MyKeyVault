import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:myapp/models/totp_account.dart';
import 'package:myapp/providers/account_provider.dart';
import 'package:myapp/screens/qr_scanner_screen.dart';
import 'package:myapp/screens/manual_input_screen.dart';
import 'package:myapp/widgets/account_list_item.dart';
import 'package:myapp/utils/time_sync.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _importAccounts(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      final file = File(result.files.single.path!);
      await Provider.of<AccountProvider>(context, listen: false)
          .importAccounts(file);
    }
  }

  Future<void> _exportAccounts(BuildContext context) async {
    final filePath =
        await Provider.of<AccountProvider>(context, listen: false)
            .exportAccounts();
    if (filePath != null) {
      await Share.shareXFiles([XFile(filePath)],
          text: 'TOTP Accounts Export');
    }
  }

  void _showTimeInfo(BuildContext context) {
    final info = TimeSync.getTimeDifferenceInfo();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('时间信息'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('使用本机UTC时间'),
            const SizedBox(height: 8),
            Text('当前UTC时间: ${info['utcTime']}', 
                 style: const TextStyle(fontSize: 12)),
            Text('时间戳: ${info['timestamp']}', 
                 style: const TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Authenticator'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'import') {
                _importAccounts(context);
              } else if (value == 'export') {
                _exportAccounts(context);
              } else if (value == 'time_info') {
                _showTimeInfo(context);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.file_download),
                    SizedBox(width: 12),
                    Text('导入账户'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.file_upload),
                    SizedBox(width: 12),
                    Text('导出账户'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'time_info',
                child: Row(
                  children: [
                    Icon(Icons.access_time),
                    SizedBox(width: 12),
                    Text('时间信息'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: accountProvider.accounts.isEmpty
          ? const Center(
              child: Text(
                'No accounts found. Add one to get started.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: accountProvider.accounts.length,
              itemBuilder: (context, index) {
                final account = accountProvider.accounts[index];
                return AccountListItem(account: account);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAccountOptions(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
