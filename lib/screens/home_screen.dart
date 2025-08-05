import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:myapp/models/totp_account.dart';
import 'package:myapp/providers/account_provider.dart';
import 'package:myapp/screens/qr_scanner_screen.dart';
import 'package:myapp/widgets/account_list_item.dart';
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
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'import',
                child: Text('Import Accounts'),
              ),
              const PopupMenuItem<String>(
                value: 'export',
                child: Text('Export Accounts'),
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const QrScannerScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
