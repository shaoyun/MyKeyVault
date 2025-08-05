import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:otp/otp.dart';

part 'totp_account.freezed.dart';
part 'totp_account.g.dart';

@freezed
abstract class TotpAccount with _$TotpAccount {
  const factory TotpAccount({
    required String id,
    required String issuer,
    required String name,
    required String secret,
  }) = _TotpAccount;

  factory TotpAccount.fromJson(Map<String, dynamic> json) =>
      _$TotpAccountFromJson(json);
}
