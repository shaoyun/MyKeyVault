import 'package:myapp/models/totp_account.dart';
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
      final String name;

      if (pathSegments.isNotEmpty) {
        name = pathSegments.first.trim();
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
      );
    } catch (e) {
      return null;
    }
  }
}
