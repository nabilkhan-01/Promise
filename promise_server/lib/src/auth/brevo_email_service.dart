import 'package:mailer/mailer.dart' as mailer;
import 'package:mailer/smtp_server.dart';
import 'package:serverpod/serverpod.dart';

class BrevoEmailService {
  /// Sends a registration verification email via Brevo SMTP.
  static Future<void> sendRegistrationVerificationCode(
    Session session, {
    required UuidValue accountRequestId,
    required String email,
    required Transaction? transaction,
    required String verificationCode,
  }) async {
    await _sendVerificationCode(
      session: session,
      recipientEmail: email,
      verificationCode: verificationCode,
      isPasswordReset: false,
    );
  }

  /// Sends a password reset verification email via Brevo SMTP.
  static Future<void> sendPasswordResetVerificationCode(
    Session session, {
    required String email,
    required UuidValue passwordResetRequestId,
    required Transaction? transaction,
    required String verificationCode,
  }) async {
    await _sendVerificationCode(
      session: session,
      recipientEmail: email,
      verificationCode: verificationCode,
      isPasswordReset: true,
    );
  }

  /// Internal method to send a verification email via Brevo SMTP.
  static Future<void> _sendVerificationCode({
    required Session session,
    required String recipientEmail,
    required String verificationCode,
    required bool isPasswordReset,
  }) async {
    final cleanEmail = recipientEmail.trim().toLowerCase();

    final host =
        session.serverpod.getPassword('brevoSmtpHost') ??
        session.passwords['brevoSmtpHost'] ??
        'smtp-relay.brevo.com';

    final portVal =
        session.serverpod.getPassword('brevoSmtpPort') ??
        session.passwords['brevoSmtpPort'] ??
        2525;
    final port = int.tryParse(portVal.toString()) ?? 2525;

    final username =
        session.serverpod.getPassword('brevoSmtpUsername') ??
        session.passwords['brevoSmtpUsername'];

    final smtpKey =
        session.serverpod.getPassword('brevoSmtpKey') ??
        session.passwords['brevoSmtpKey'];

    final senderEmail =
        session.serverpod.getPassword('brevoSenderEmail') ??
        session.passwords['brevoSenderEmail'] ??
        'noreply@example.com';

    final senderName =
        session.serverpod.getPassword('brevoSenderName') ??
        session.passwords['brevoSenderName'] ??
        'Promise';

    if (username == null ||
        username.trim().isEmpty ||
        smtpKey == null ||
        smtpKey.trim().isEmpty) {
      session.log(
        '[EmailIDP] Brevo SMTP credentials not configured in passwords.yaml',
        level: LogLevel.error,
      );
      return;
    }

    final subject = isPasswordReset
        ? 'Your Promise Password Reset Code'
        : 'Your Promise Verification Code';

    final actionTitle = isPasswordReset
        ? 'Reset Your Password'
        : 'Verify Your Email Address';

    final bodyText =
        '''
Promise

$actionTitle

Your verification code is: $verificationCode

Enter this code in the Promise app to continue.

This code is for your Promise account and should not be shared with anyone.
If you did not request this code, you can ignore this email.

Regards,
Promise Team
''';

    final bodyHtml =
        '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background-color: #f4f5f8; margin: 0; padding: 20px; color: #1a1c1e; }
    .card { max-width: 480px; margin: 0 auto; background: #ffffff; border-radius: 16px; padding: 32px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); }
    .logo { font-size: 24px; font-weight: bold; color: #3f51b5; margin-bottom: 24px; }
    .title { font-size: 20px; font-weight: bold; margin-bottom: 12px; color: #1a1c1e; }
    .text { font-size: 14px; line-height: 1.5; color: #44474e; margin-bottom: 24px; }
    .code-box { background-color: #eef0ff; border-radius: 12px; padding: 16px; text-align: center; margin-bottom: 24px; }
    .code { font-size: 32px; font-weight: bold; letter-spacing: 6px; color: #3f51b5; }
    .footer { font-size: 12px; color: #74777f; text-align: center; margin-top: 24px; }
  </style>
</head>
<body>
  <div class="card">
    <div class="logo">Promise</div>
    <div class="title">$actionTitle</div>
    <div class="text">
      Use the verification code below to ${isPasswordReset ? 'reset your password' : 'complete your registration'}.
    </div>
    <div class="code-box">
      <div class="code">$verificationCode</div>
    </div>
    <div class="text">
      This code is for your Promise account and should not be shared with anyone.<br>
      If you did not request this code, please ignore this email.
    </div>
    <div class="footer">
      © Promise — Keep commitments clear, trackable, and documented.
    </div>
  </div>
</body>
</html>
''';

    session.log(
      '[EmailIDP] Attempting Brevo SMTP delivery for $cleanEmail (${isPasswordReset ? 'PasswordReset' : 'Registration'})',
      level: LogLevel.info,
    );

    final smtpServer = SmtpServer(
      host,
      port: port,
      ssl: false,
      allowInsecure: false,
      username: username,
      password: smtpKey,
    );

    final message = mailer.Message()
      ..from = mailer.Address(senderEmail, senderName)
      ..recipients.add(cleanEmail)
      ..subject = subject
      ..text = bodyText
      ..html = bodyHtml;

    try {
      final sendReport = await mailer.send(message, smtpServer);
      session.log(
        '[EmailIDP] Brevo SMTP delivery succeeded for $cleanEmail (Report: ${sendReport.toString().split(' ').first})',
        level: LogLevel.info,
      );
    } catch (e, stack) {
      session.log(
        '[EmailIDP] Brevo SMTP delivery failed for $cleanEmail: $e',
        level: LogLevel.error,
        exception: e,
        stackTrace: stack,
      );
      throw Exception('BrevoDeliveryError');
    }
  }
}
