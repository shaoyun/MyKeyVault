import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/account_provider.dart';
import 'package:myapp/widgets/account_list_item.dart';
import 'package:myapp/widgets/add_account_screen.dart';
import 'package:myapp/screens/qr_scanner_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart'; // 添加 share_plus 库进行文件分享

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _exportAccounts(BuildContext context) async {
    try {
      final status = await Permission.storage.request();
      if (status.isGranted) {
        final provider = Provider.of<AccountProvider>(context, listen: false);
        final jsonString = await provider.exportAccounts();

        final directory = await getApplicationDocumentsDirectory(); // 使用应用文档目录，更稳定
        if (directory != null) {
          final filePath = '${directory.path}/totp_accounts.json';
          final file = File(filePath);
          await file.writeAsString(jsonString);

          // 提供分享功能，让用户选择保存位置
           await Share.shareFiles([filePath], text: 'TOTP Accounts Export');


          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('账户已导出')),
          );
        } else {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('无法获取应用文档目录')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('需要存储权限才能导出')),
        );
      }
    } catch (e) {
      print("导出错误: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('导出账户失败')),
      );
    }
  }

  Future<void> _importAccounts(BuildContext context) async {
     try {
      final status = await Permission.storage.request();
      if (status.isGranted) {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['json'],
        );

        if (result != null && result.files.single.path != null) {
          final filePath = result.files.single.path!;
          final file = File(filePath);
          final jsonString = await file.readAsString();
          final provider = Provider.of<AccountProvider>(context, listen: false);
          provider.importAccounts(jsonString);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('账户已成功导入')),
          );
        } else {
           // 用户取消了文件选择
        }
      } else {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('需要存储权限才能导入')),
        );
      }
    } catch (e) {
      print("导入错误: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('导入账户失败')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final accountProvider = Provider.of<AccountProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('OneTimePass'),
        actions: [
           PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'export') {
                _exportAccounts(context);
              } else if (value == 'import') {
                _importAccounts(context);
              } else if (value == 'clear') { // 添加清空账户选项 (仅用于开发/测试)
                 showDialog(
                   context: context,
                   builder: (context) => AlertDialog(
                     title: const Text('清空所有账户?'),
                     content: const Text('这将永久删除所有账户，确定吗?'),
                     actions: [
                       TextButton(
                         onPressed: () => Navigator.pop(context),
                         child: const Text('取消'),
                       ),
                       TextButton(
                         onPressed: () {
                           accountProvider.clearAccounts();
                           Navigator.pop(context);
                         },
                         child: const Text('清空'),
                       ),
                     ],
                   ),
                 );
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'export',
                  child: Text('导出账户'),
                ),
                const PopupMenuItem<String>(
                  value: 'import',
                  child: Text('导入账户'),
                ),
                 // 仅在 debug 模式下显示清空选项
                if (kDebugMode) // 需要 import 'package:flutter/foundation.dart';
                 const PopupMenuItem<String>(
                  value: 'clear',
                  child: Text('清空所有账户'),
                ),
              ];
            },
          ),
        ],
      ),
      body: accountProvider.accounts.isEmpty
          ? const Center(
              child: Text(
                '点击右下角按钮添加您的第一个账户',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
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
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      leading: const Icon(Icons.add),
                      title: const Text('手动添加账户'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                           context,
                           MaterialPageRoute(builder: (context) => AddAccountScreen()),
                         );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.qr_code_scanner),
                      title: const Text('扫描二维码'),
                      onTap: () {
                        Navigator.pop(context);
                         Navigator.push(
                           context,
                           MaterialPageRoute(builder: (context) => QrScannerScreen()),
                         );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        tooltip: '添加账户',
        child: const Icon(Icons.add),
      ),
    );
  }
}
