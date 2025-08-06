import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mykeyvault/models/totp_account.dart';
import 'package:mykeyvault/providers/account_provider.dart';
import 'package:mykeyvault/screens/edit_account_screen.dart';
import 'package:mykeyvault/utils/time_sync.dart';
import 'package:otp/otp.dart';
import 'package:provider/provider.dart';

class AccountListItem extends StatefulWidget {
  final TotpAccount account;

  const AccountListItem({super.key, required this.account});

  @override
  _AccountListItemState createState() => _AccountListItemState();
}

class _AccountListItemState extends State<AccountListItem> {
  late Timer _timer;
  String _currentOtp = '';
  double _timeRemaining = 1.0;

  @override
  void initState() {
    super.initState();
    _generateOtp();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        // 使用同步后的时间戳确保准确性
        final now = TimeSync.getSyncedTimestampSeconds();
        final timeInPeriod = now % 30;
        _timeRemaining = 1.0 - (timeInPeriod / 30);
        if (timeInPeriod == 0) {
          _generateOtp();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _generateOtp() {
    // 使用同步后的秒级时间戳，TOTP标准要求使用秒级时间戳
    final syncedTimestampSeconds = TimeSync.getSyncedTimestampSeconds();
    
    // OTP库的generateTOTPCodeString方法期望秒级时间戳，不是毫秒
    _currentOtp = OTP.generateTOTPCodeString(
        widget.account.secret, syncedTimestampSeconds, length: 6, interval: 30);
        
    if (kDebugMode) {
      print('TOTP Debug - Account: ${widget.account.name}, UTC Timestamp: $syncedTimestampSeconds, Code: $_currentOtp');
    }
  }

  void _showAccountOptions(BuildContext context) {
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
              Text(
                '${widget.account.name}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${widget.account.issuer}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(
                  Icons.edit,
                  color: Colors.blue,
                  size: 28,
                ),
                title: const Text('编辑账户'),
                subtitle: const Text('修改账户信息和密钥'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditAccountScreen(account: widget.account),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.copy,
                  color: Colors.green,
                  size: 28,
                ),
                title: const Text('复制验证码'),
                subtitle: Text('复制当前验证码：$_currentOtp'),
                onTap: () {
                  Navigator.pop(context);
                  Clipboard.setData(ClipboardData(text: _currentOtp));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('验证码已复制到剪贴板！'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete,
                  color: Colors.red,
                  size: 28,
                ),
                title: const Text('删除账户'),
                subtitle: const Text('永久删除此账户'),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除账户'),
        content: Text(
            '确定要删除 ${widget.account.name} (${widget.account.issuer}) 吗？\n\n此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<AccountProvider>(context, listen: false)
                  .deleteAccount(widget.account);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('账户已删除'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
              widget.account.issuer.isNotEmpty ? widget.account.issuer[0].toUpperCase() : '?'),
        ),
        title: Text(widget.account.name),
        subtitle: Text(widget.account.issuer),
        trailing: SizedBox(
          width: 80,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _currentOtp,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  value: _timeRemaining,
                  strokeWidth: 2,
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          Clipboard.setData(ClipboardData(text: _currentOtp));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('验证码 $_currentOtp 已复制到剪贴板！'),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
        },
        onLongPress: () {
          _showAccountOptions(context);
        },
      ),
    );
  }
}
