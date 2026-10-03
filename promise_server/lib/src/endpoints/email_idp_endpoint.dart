import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import '../auth/disposable_email_validator.dart';

class EmailIdpEndpoint extends EmailIdpBaseEndpoint {
  @override
  Future<UuidValue> startRegistration(
    Session session, {
    required String email,
  }) async {
    final cleanEmail = DisposableEmailValidator.validateAndNormalize(email);
    return super.startRegistration(session, email: cleanEmail);
  }

  @override
  Future<AuthSuccess> login(
    Session session, {
    required String email,
    required String password,
  }) async {
    final cleanEmail = DisposableEmailValidator.validateAndNormalize(email);
    return super.login(session, email: cleanEmail, password: password);
  }

  @override
  Future<UuidValue> startPasswordReset(
    Session session, {
    required String email,
  }) async {
    final cleanEmail = DisposableEmailValidator.validateAndNormalize(email);

    final account = await EmailAccount.db.findFirstRow(
      session,
      where: (t) => t.email.equals(cleanEmail),
    );
    if (account == null) {
      throw EmailAccountPasswordResetException(
        reason: EmailAccountPasswordResetExceptionReason.unknown,
      );
    }

    return super.startPasswordReset(session, email: cleanEmail);
  }
}
