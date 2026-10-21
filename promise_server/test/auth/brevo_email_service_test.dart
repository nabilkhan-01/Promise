import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:promise_server/src/auth/brevo_email_service.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';
import '../integration/test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given BrevoEmailService email delivery', (
    sessionBuilder,
    endpoints,
  ) {
    test(
      'successful registration email delivery with valid credentials',
      () async {
        final session = sessionBuilder.build();

        final mockClient = MockClient((request) async {
          expect(
            request.url.toString(),
            equals('https://api.brevo.com/v3/smtp/email'),
          );
          expect(request.headers['api-key'], equals('test-api-key-123'));

          final body = jsonDecode(request.body);
          expect(body['sender']['email'], equals('verified@promise.app'));
          expect(body['to'][0]['email'], equals('user@example.com'));
          expect(body['subject'], contains('Promise Verification Code'));

          return http.Response(
            jsonEncode({
              'messageId': '<202610141234.123456@smtp-relay.brevo.com>',
            }),
            201,
          );
        });

        session.passwords['brevoApiKey'] = 'test-api-key-123';
        session.passwords['brevoSenderEmail'] = 'verified@promise.app';
        session.passwords['brevoSenderName'] = 'Promise';

        await expectLater(
          BrevoEmailService.sendRegistrationVerificationCode(
            session,
            accountRequestId: UuidValue.fromString(
              '11111111-1111-4111-a111-111111111111',
            ),
            email: 'user@example.com',
            transaction: null,
            verificationCode: '123456',
            httpClient: mockClient,
          ),
          completes,
        );
      },
    );

    test('successful password reset email delivery', () async {
      final session = sessionBuilder.build();

      final mockClient = MockClient((request) async {
        final body = jsonDecode(request.body);
        expect(body['subject'], contains('Password Reset Code'));

        return http.Response(
          jsonEncode({'messageId': '<pwd-reset-999@smtp-relay.brevo.com>'}),
          200,
        );
      });

      session.passwords['brevoApiKey'] = 'test-api-key-123';
      session.passwords['brevoSenderEmail'] = 'verified@promise.app';

      await expectLater(
        BrevoEmailService.sendPasswordResetVerificationCode(
          session,
          passwordResetRequestId: UuidValue.fromString(
            '22222222-2222-4222-a222-222222222222',
          ),
          email: 'user@example.com',
          transaction: null,
          verificationCode: '654321',
          httpClient: mockClient,
        ),
        completes,
      );
    });

    test('fails clearly when brevoApiKey is missing', () async {
      final session = sessionBuilder.build();
      session.passwords.remove('brevoApiKey');
      session.passwords['brevoSenderEmail'] = 'verified@promise.app';

      await expectLater(
        BrevoEmailService.sendRegistrationVerificationCode(
          session,
          accountRequestId: UuidValue.fromString(
            '11111111-1111-4111-a111-111111111111',
          ),
          email: 'user@example.com',
          transaction: null,
          verificationCode: '123456',
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('BrevoDeliveryError'),
          ),
        ),
      );
    });

    test(
      'fails clearly when brevoSenderEmail is a placeholder or missing',
      () async {
        final session = sessionBuilder.build();
        session.passwords['brevoApiKey'] = 'test-api-key-123';
        session.passwords['brevoSenderEmail'] = 'noreply@example.com';

        await expectLater(
          BrevoEmailService.sendRegistrationVerificationCode(
            session,
            accountRequestId: UuidValue.fromString(
              '11111111-1111-4111-a111-111111111111',
            ),
            email: 'user@example.com',
            transaction: null,
            verificationCode: '123456',
          ),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('BrevoDeliveryError'),
            ),
          ),
        );
      },
    );

    test(
      'throws BrevoDeliveryError when Brevo API rejects request with 400 Bad Request',
      () async {
        final session = sessionBuilder.build();

        final mockClient = MockClient((request) async {
          return http.Response(
            jsonEncode({
              'code': 'invalid_parameter',
              'message': 'sender email not verified',
            }),
            400,
          );
        });

        session.passwords['brevoApiKey'] = 'test-api-key-123';
        session.passwords['brevoSenderEmail'] = 'unverified@customdomain.com';

        await expectLater(
          BrevoEmailService.sendRegistrationVerificationCode(
            session,
            accountRequestId: UuidValue.fromString(
              '11111111-1111-4111-a111-111111111111',
            ),
            email: 'user@example.com',
            transaction: null,
            verificationCode: '123456',
            httpClient: mockClient,
          ),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('BrevoDeliveryError'),
            ),
          ),
        );
      },
    );

    test('throws BrevoDeliveryError on network exception', () async {
      final session = sessionBuilder.build();

      final mockClient = MockClient((request) async {
        throw http.ClientException('Network unreachable');
      });

      session.passwords['brevoApiKey'] = 'test-api-key-123';
      session.passwords['brevoSenderEmail'] = 'verified@promise.app';

      await expectLater(
        BrevoEmailService.sendRegistrationVerificationCode(
          session,
          accountRequestId: UuidValue.fromString(
            '11111111-1111-4111-a111-111111111111',
          ),
          email: 'user@example.com',
          transaction: null,
          verificationCode: '123456',
          httpClient: mockClient,
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('BrevoDeliveryError'),
          ),
        ),
      );
    });
  });
}
