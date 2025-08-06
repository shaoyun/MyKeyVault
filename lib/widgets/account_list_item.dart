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
        // 使用同步后的秒级时间戳计算剩余时间
        final nowSeconds = TimeSync.getSyncedTimestampSeconds();
        final timeInPeriod = nowSeconds % 30;
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
    // 使用同步后的毫秒级时间戳，Dart OTP库要求使用毫秒级时间戳
    final syncedTimestampMillis = TimeSync.getSyncedTimestamp();
    
    // OTP库的generateTOTPCodeString方法期望毫秒级时间戳
    // 使用正确的参数组合：毫秒 + SHA1 + isGoogle=true
    _currentOtp = OTP.generateTOTPCodeString(
        widget.account.secret, 
        syncedTimestampMillis, 
        length: 6, 
        interval: 30, 
        algorithm: Algorithm.SHA1,
        isGoogle: true);
        
    if (kDebugMode) {
      print('TOTP Debug - Account: ${widget.account.name}, UTC Timestamp (ms): $syncedTimestampMillis, Code: $_currentOtp, Algorithm: SHA1');
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

  // 获取卡片颜色
  Color _getCardColor() {
    switch (widget.account.colorType) {
      case 'pink': return const Color(0xFFEC407A);
      case 'crimson': return const Color(0xFFE91E63);
      case 'purple': return const Color(0xFF9C27B0);
      case 'violet': return const Color(0xFF673AB7);
      case 'deepPurple': return const Color(0xFF512DA8);
      case 'indigo': return const Color(0xFF3F51B5);
      case 'blue': return const Color(0xFF2196F3);
      case 'lightBlue': return const Color(0xFF03A9F4);
      case 'cyan': return const Color(0xFF00BCD4);
      case 'teal': return const Color(0xFF009688);
      case 'green': return const Color(0xFF4CAF50);
      case 'lightGreen': return const Color(0xFF8BC34A);
      case 'lime': return const Color(0xFFCDDC39);
      case 'grey': return const Color(0xFF9E9E9E);
      case 'yellow': return const Color(0xFFFFC107);
      case 'amber': return const Color(0xFFFF9800);
      case 'orange': return const Color(0xFFFF5722);
      case 'deepOrange': return const Color(0xFFE65100);
      case 'red': return const Color(0xFFf44336);
      case 'deepRed': return const Color(0xFFD32F2F);
      case 'brown': return const Color(0xFF795548);
      case 'blueGrey': return const Color(0xFF607D8B);
      case 'darkGrey': return const Color(0xFF424242);
      default: return const Color(0xFF2196F3); // 默认蓝色
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = _getCardColor();
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: cardColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // 左侧内容区域
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 发行方
                    Text(
                      widget.account.issuer,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // 账户名
                    Text(
                      widget.account.name,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // 验证码
                    Text(
                      _currentOtp,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              // 右侧时间环
              Column(
                children: [
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      value: _timeRemaining,
                      strokeWidth: 3,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
