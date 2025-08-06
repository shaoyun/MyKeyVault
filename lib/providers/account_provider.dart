import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mykeyvault/models/totp_account.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountProvider with ChangeNotifier {
  final List<TotpAccount> _accounts = [];
  static const _prefsKey = 'totp_accounts';

  List<TotpAccount> get accounts => _accounts;

  Future<void> addAccount(TotpAccount account) async {
    final existingAccount = _accounts.where(
      (a) => a.issuer == account.issuer && a.name == account.name,
    );

    if (existingAccount.isNotEmpty) {
      if (kDebugMode) {
        print("Account already exists: ${account.issuer} - ${account.name}");
      }
      return;
    }
    _accounts.add(account);
    await _saveAccounts();
    notifyListeners();
  }

  Future<void> _saveAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> accountList =
        _accounts.map((account) => jsonEncode(account.toJson())).toList();
    await prefs.setStringList(_prefsKey, accountList);
  }

  Future<void> loadAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? accountList = prefs.getStringList(_prefsKey);
    if (accountList != null) {
      _accounts.clear();
      for (final String accountJson in accountList) {
        _accounts.add(TotpAccount.fromJson(jsonDecode(accountJson)));
      }
      notifyListeners();
    }
  }

  Future<void> deleteAccount(TotpAccount account) async {
    _accounts.remove(account);
    await _saveAccounts();
    notifyListeners();
  }

  Future<void> updateAccount(TotpAccount oldAccount, TotpAccount newAccount) async {
    final index = _accounts.indexOf(oldAccount);
    if (index != -1) {
      _accounts[index] = newAccount;
      await _saveAccounts();
      notifyListeners();
    }
  }

  Future<String?> exportAccounts() async {
    try {
      final List<Map<String, dynamic>> exportData =
          _accounts.map((account) => account.toJson()).toList();
      final String jsonString = jsonEncode(exportData);
      final Directory directory = await getApplicationDocumentsDirectory();
      final String filePath = '${directory.path}/totp_accounts.json';
      final File file = File(filePath);
      await file.writeAsString(jsonString);
      return filePath;
    } catch (e) {
      if (kDebugMode) {
        print('Error exporting accounts: $e');
      }
      return null;
    }
  }

  Future<void> importAccounts(File file) async {
    try {
      final String jsonString = await file.readAsString();
      final List<dynamic> importData = jsonDecode(jsonString);
      for (final dynamic item in importData) {
        final TotpAccount importedAccount = TotpAccount.fromJson(item);
        final bool accountExists = _accounts.any(
          (a) =>
              a.issuer == importedAccount.issuer &&
              a.name == importedAccount.name,
        );
        if (!accountExists) {
          _accounts.add(importedAccount);
        } else {
          if (kDebugMode) {
            print(
                "Skipping duplicate account during import: ${importedAccount.issuer} - ${importedAccount.name}");
          }
        }
      }
      await _saveAccounts();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error importing accounts: $e');
      }
    }
  }
}
