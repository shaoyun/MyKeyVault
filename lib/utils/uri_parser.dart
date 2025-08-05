import 'package:uri/uri.dart';
import 'package:myapp/models/totp_account.dart';
import 'package:base32/base32.dart'; // 用于验证密钥是否为 Base32

TotpAccount? parseTotpUri(String uriString) {
  try {
    final uri = Uri.parse(uriString);
    if (uri.scheme != 'otpauth' || uri.host != 'totp') {
      return null; // 不是有效的 TOTP URI
    }

    // Path 通常包含发行商和账户名
    // 格式可能是 /账户名 或 /发行商:账户名
    String path = uri.pathSegments.join('/');
    String issuer = '未知发行商';
    String accountName = '';

    if (path.contains(':')) {
      final parts = path.split(':');
      issuer = parts[0].trim();
      accountName = parts.sublist(1).join(':').trim(); // 处理账户名中包含冒号的情况
    } else {
      accountName = path.trim();
    }

    final parameters = uri.queryParameters;
    final secret = parameters['secret'];
    if (secret == null || secret.isEmpty) {
      print("TOTP URI 解析错误: 密钥缺失");
      return null; // 密钥是必须的
    }

    // 验证密钥是否为 Base32 编码
    try {
      base32.decode(secret);
    } catch (e) {
       print("TOTP URI 解析错误: 密钥不是有效的 Base32 编码");
       return null;
    }


    final digits = int.tryParse(parameters['digits'] ?? '') ?? 6;
    final period = int.tryParse(parameters['period'] ?? '') ?? 30;
    final algorithm = parameters['algorithm']?.toUpperCase() ?? 'SHA1'; // 默认为 SHA1 并转换为大写

    // 优先使用 query 参数中的 issuer
    final finalIssuer = parameters['issuer'] ?? issuer;


    return TotpAccount(
      issuer: finalIssuer,
      accountName: accountName,
      secret: secret,
      digits: digits,
      period: period,
      algorithm: algorithm,
    );
  } catch (e) {
    print("TOTP URI 解析错误: $e");
    return null;
  }
}
