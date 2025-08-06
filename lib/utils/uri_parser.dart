import 'package:mykeyvault/models/totp_account.dart';
import 'package:uuid/uuid.dart';

class UriParser {
  static TotpAccount? parse(String uriString) {
    try {
      final uri = Uri.parse(uriString);
      if (uri.scheme != 'otpauth' || uri.host != 'totp') {
        return null;
      }

      final issuer = uri.queryParameters['issuer'] ?? '';
      final secret = uri.queryParameters['secret'];
      final pathSegments = uri.pathSegments;
      String name;

      if (pathSegments.isNotEmpty) {
        String rawName = pathSegments.first.trim();
        
        // 如果path包含 "issuer:" 前缀，去除它以提取真正的账户名
        if (issuer.isNotEmpty && rawName.startsWith('$issuer:')) {
          name = rawName.substring(issuer.length + 1);
        } else {
          name = rawName;
        }
        
        // 处理边缘情况：如果name只是一个冒号或为空，尝试使用完整的path
        if (name == ':' || name.isEmpty) {
          name = rawName;
        }
      } else {
        name = '';
      }

      if (secret == null || secret.isEmpty) {
        return null;
      }

      return TotpAccount(
        id: const Uuid().v4(),
        issuer: issuer,
        name: name,
        secret: secret,
        colorType: 'default',
      );
    } catch (e) {
      return null;
    }
  }
}
