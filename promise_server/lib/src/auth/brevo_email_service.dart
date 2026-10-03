import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';

class BrevoEmailService {
  /// Sends a registration verification email via Brevo REST API.
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

  /// Sends a password reset verification email via Brevo REST API.
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

  /// Internal method to send a verification email via Brevo Transactional Email REST API.
  /// Uses POST https://api.brevo.com/v3/smtp/email over HTTPS (port 443).
  static Future<void> _sendVerificationCode({
    required Session session,
    required String recipientEmail,
    required String verificationCode,
    required bool isPasswordReset,
  }) async {
    final cleanEmail = recipientEmail.trim().toLowerCase();

    final apiKey =
        session.serverpod.getPassword('brevoApiKey') ??
        session.passwords['brevoApiKey'];

    final senderEmail =
        session.serverpod.getPassword('brevoSenderEmail') ??
        session.passwords['brevoSenderEmail'] ??
        'noreply@example.com';

    final senderName =
        session.serverpod.getPassword('brevoSenderName') ??
        session.passwords['brevoSenderName'] ??
        'Promise';

    if (apiKey == null || apiKey.trim().isEmpty) {
      session.log(
        '[EmailIDP] brevoApiKey secret not configured in passwords.yaml / Cloud secrets',
        level: LogLevel.error,
      );
      throw Exception('BrevoDeliveryError');
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
      '[EmailIDP] Attempting Brevo API email delivery for $cleanEmail (${isPasswordReset ? 'PasswordReset' : 'Registration'})',
      level: LogLevel.info,
    );

    try {
      final response = await http.post(
        Uri.parse('https://api.brevo.com/v3/smtp/email'),
        headers: {
          'accept': 'application/json',
          'api-key': apiKey.trim(),
          'content-type': 'application/json',
        },
        body: jsonEncode({
          'sender': {
            'name': senderName,
            'email': senderEmail,
          },
          'to': [
            {
              'email': cleanEmail,
            },
          ],
          'subject': subject,
          'htmlContent': bodyHtml,
          'textContent': bodyText,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        session.log(
          '[EmailIDP] Brevo API email delivery succeeded for $cleanEmail (Status: ${response.statusCode})',
          level: LogLevel.info,
        );
        return;
      } else {
        final safeResponseBody = response.body.length > 300
            ? '${response.body.substring(0, 300)}...'
            : response.body;
        session.log(
          '[EmailIDP] Brevo API delivery failed for $cleanEmail (Status: ${response.statusCode}, Body: $safeResponseBody)',
          level: LogLevel.error,
        );
        throw Exception('BrevoDeliveryError');
      }
    } catch (e, stack) {
      if (e is! Exception || !e.toString().contains('BrevoDeliveryError')) {
        session.log(
          '[EmailIDP] Brevo API connection error for $cleanEmail: $e',
          level: LogLevel.error,
          exception: e,
          stackTrace: stack,
        );
      }
      throw Exception('BrevoDeliveryError');
    }
  }
}
