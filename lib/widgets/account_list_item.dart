import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/models/totp_account.dart';
import 'package:myapp/providers/account_provider.dart';
import 'dart:async';
import 'package:flutter/services.dart'; // 用于复制到剪贴板

class AccountListItem extends StatefulWidget {
  final TotpAccount account;

  const AccountListItem({Key? key, required this.account}) : super(key: key);

  @override
  _AccountListItemState createState() => _AccountListItemState();
}

class _AccountListItemState extends State<AccountListItem> {
  String _currentOtp = '';
  Timer? _timer;
  double _timeRemaining = 0; // 剩余时间百分比

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _updateOtp();
    // 每 200 毫秒更新一次进度条，每秒更新 OTP
    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final timeInPeriod = now % widget.account.period;
      _timeRemaining = 1.0 - (timeInPeriod / widget.account.period);

      // 在每个周期的开始更新 OTP
      if (timeInPeriod == 0) {
        _updateOtp();
      }

       if(mounted) { // 检查widget是否挂载
         setState(() {});
       }
    });
  }

  void _updateOtp() {
    try {
      _currentOtp = widget.account.generateOtp();
    } catch (e) {
      _currentOtp = "Error"; // 处理 OTP 生成错误
      print("OTP 生成错误: $e");
      // TODO: 可以考虑显示更详细的错误信息给用户
    }

    if(mounted) { // 检查widget是否挂载
       setState(() {});
    }
  }

  void _copyOtp() {
    Clipboard.setData(ClipboardData(text: _currentOtp));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP 已复制')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accountProvider = Provider.of<AccountProvider>(context, listen: false);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2.0,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          child: Text(
            widget.account.issuer.isNotEmpty ? widget.account.issuer[0].toUpperCase() : '?',
            style: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
          ),
        ),
        title: Text(
          widget.account.issuer,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.account.accountName,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4.0),
            LinearProgressIndicator(
              value: _timeRemaining,
              backgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
              color: _timeRemaining > 0.15 ? Theme.of(context).colorScheme.primary : Colors.redAccent, // 时间快到时变红，留一点余量
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _currentOtp,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.copy),
              tooltip: '复制 OTP',
              onPressed: _copyOtp,
            ),
             IconButton(
              icon: const Icon(Icons.delete),
              tooltip: '删除账户',
               onPressed: () {
                 showDialog(
                   context: context,
                   builder: (context) => AlertDialog(
                     title: const Text('确认删除'),
                     content: Text('确定要删除账户 ${widget.account.accountName} (${widget.account.issuer}) 吗?'),
                     actions: [
                       TextButton(
                         onPressed: () => Navigator.pop(context),
                         child: const Text('取消'),
                       ),
                       TextButton(
                         onPressed: () {
                           accountProvider.removeAccount(widget.account);
                           Navigator.pop(context);
                         },
                         child: const Text('删除'),
                       ),
                     ],
                   ),
                 );
               },
            ),
          ],
        ),
      ),
    );
  }
}
