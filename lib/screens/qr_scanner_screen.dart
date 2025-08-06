import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:myapp/models/totp_account.dart';
import 'package:myapp/providers/account_provider.dart';
import 'package:myapp/utils/uri_parser.dart';
import 'package:provider/provider.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  QrScannerScreenState createState() => QrScannerScreenState();
}

class QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _controller.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder<TorchState>(
              valueListenable: _controller.torchState,
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                  case TorchState.auto:
                    return const Icon(Icons.flash_auto, color: Colors.grey);
                }
              },
            ),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: ValueListenableBuilder<CameraFacing>(
              valueListenable: _controller.cameraFacingState,
              builder: (context, state, child) {
                return state == CameraFacing.front
                    ? const Icon(Icons.camera_front)
                    : const Icon(Icons.camera_rear);
              },
            ),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: MobileScanner(
        controller: _controller,
        onDetect: (capture) {
          if (_isProcessing) return;

          final String? value = capture.barcodes.first.rawValue;
          if (value == null) {
            log('Failed to scan QR code');
            _showErrorSnackBar('Invalid QR code. Please try again.');
            return;
          }

          setState(() {
            _isProcessing = true;
          });

          try {
            final TotpAccount? account = UriParser.parse(value);
            if (account != null) {
              Provider.of<AccountProvider>(context, listen: false)
                  .addAccount(account);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account added successfully!'),
                  duration: Duration(seconds: 2),
                ),
              );
            } else {
              _showErrorSnackBar('Invalid QR code format.');
            }
          } catch (e) {
            _showErrorSnackBar('An error occurred: ${e.toString()}');
          } finally {
            // Add a short delay before allowing another scan
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                setState(() {
                  _isProcessing = false;
                });
              }
            });
          }
        },
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
