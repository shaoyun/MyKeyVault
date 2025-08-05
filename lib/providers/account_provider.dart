import 'package:flutter/material.dart';
import 'package:myapp/models/totp_account.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AccountProvider with ChangeNotifier {
  List<TotpAccount> _accounts = [];

  List<TotpAccount> get accounts => _accounts;

  AccountProvider() {
    _loadAccounts();
  }

  void addAccount(TotpAccount account) {
    // 检查是否已经存在相同发行商和账户名的账户
    bool exists = _accounts.any(
      (a) => a.issuer == account.issuer && a.accountName == account.accountName,
    );
    if (exists) {
      // TODO: 提示用户账户已存在，是否覆盖或取消
      print(
        "Account already exists: ${account.issuer} - ${account.accountName}",
      );
      return;
    }
    _accounts.add(account);
    _saveAccounts();
    notifyListeners();
  }

  void removeAccount(TotpAccount account) {
    _accounts.remove(account);
    _saveAccounts();
    notifyListeners();
  }

  void _saveAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final accountListJson =
        _accounts.map((account) => account.toJson()).toList();
    prefs.setString('totp_accounts', jsonEncode(accountListJson));
  }

  void _loadAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final accountListJsonString = prefs.getString('totp_accounts');
    if (accountListJsonString != null) {
      try {
        final accountListJson =
            jsonDecode(accountListJsonString) as List<dynamic>;
        _accounts =
            accountListJson.map((json) => TotpAccount.fromJson(json)).toList();
      } catch (e) {
        print("Error loading accounts: $e");
        // TODO: 处理加载错误，例如数据损坏，可以清空本地存储或提示用户
      }
      notifyListeners();
    }
  }

  // 导出账户配置
  Future<String> exportAccounts() async {
    final accountListJson =
        _accounts.map((account) => account.toJson()).toList();
    return jsonEncode(accountListJson);
  }

  // 导入账户配置
  void importAccounts(String jsonString) {
    try {
      final accountListJson = jsonDecode(jsonString) as List<dynamic>;
      final importedAccounts =
          accountListJson.map((json) => TotpAccount.fromJson(json)).toList();

      // 合并导入的账户，避免重复
      for (var importedAccount in importedAccounts) {
        bool exists = _accounts.any(
          (a) =>
              a.issuer == importedAccount.issuer &&
              a.accountName == importedAccount.accountName,
        );
        if (!exists) {
          _accounts.add(importedAccount);
        } else {
          // TODO: 提示用户有重复账户未导入或提供覆盖选项
          print(
            "Skipping duplicate account during import: ${importedAccount.issuer} - ${importedAccount.accountName}",
          );
        }
      }

      _saveAccounts();
      notifyListeners();
    } catch (e) {
      print("Error importing accounts: $e");
      // TODO: Handle import errors (e.g., show a dialog to the user)
    }
  }

  // 清空所有账户 (用于开发或测试)
  void clearAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('totp_accounts');
    _accounts = [];
    notifyListeners();
    print("All accounts cleared.");
  }
}
