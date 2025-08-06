import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/models/totp_account.dart';
import 'package:myapp/providers/account_provider.dart';
import 'package:myapp/utils/time_sync.dart';
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
    // 使用同步后的时间戳，确保跨时区和虚拟机环境的一致性
    final syncedTimestamp = TimeSync.getSyncedTimestamp();
    _currentOtp = OTP.generateTOTPCodeString(
        widget.account.secret, syncedTimestamp, length: 6, interval: 30);
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
            const SnackBar(
              content: Text('Copied to clipboard!'),
              duration: Duration(seconds: 1),
            ),
          );
        },
        onLongPress: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Account'),
              content: Text(
                  'Are you sure you want to delete ${widget.account.name} (${widget.account.issuer})?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Provider.of<AccountProvider>(context, listen: false)
                        .deleteAccount(widget.account);
                    Navigator.pop(context);
                  },
                  child: const Text('Delete'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
