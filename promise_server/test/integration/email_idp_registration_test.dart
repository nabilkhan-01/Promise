import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  setUpAll(() {
    try {
      AuthServices.instance;
    } catch (_) {
      AuthServices.set(
        tokenManagerBuilders: [JwtConfigFromPasswords()],
        identityProviderBuilders: [
          EmailIdpConfigFromPasswords(
            sendRegistrationVerificationCode:
                (
                  session, {
                  required email,
                  required accountRequestId,
                  required verificationCode,
                  transaction,
                }) async {},
            sendPasswordResetVerificationCode:
                (
                  session, {
                  required email,
                  required passwordResetRequestId,
                  required verificationCode,
                  transaction,
                }) async {},
          ),
        ],
      );
    }
  });

  withServerpod('Given EmailIdp Endpoint registration', (
    sessionBuilder,
    endpoints,
  ) {
    test(
      'signing up with an existing registered email returns duplicate account error',
      () async {
        final session = sessionBuilder.build();
        const existingEmail = 'registered@example.com';

        final authUser = await AuthUser.db.insertRow(
          session,
          AuthUser(
            createdAt: DateTime.now().toUtc(),
            scopeNames: {},
          ),
        );

        await EmailAccount.db.insertRow(
          session,
          EmailAccount(
            authUserId: authUser.id!,
            email: existingEmail,
            passwordHash: 'dummy_hash',
            createdAt: DateTime.now().toUtc(),
          ),
        );

        final initialRequestCount = await EmailAccountRequest.db.count(
          session,
        );

        await expectLater(
          endpoints.emailIdp.startRegistration(
            sessionBuilder,
            email: '  Registered@EXAMPLE.com  ',
          ),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('already exists'),
            ),
          ),
        );

        final finalRequestCount = await EmailAccountRequest.db.count(session);
        expect(finalRequestCount, equals(initialRequestCount));
      },
    );

    test(
      'genuinely new email initiates registration with normalized email',
      () async {
        final session = sessionBuilder.build();
        const rawEmail = '  NewUser@EXAMPLE.com  ';
        const cleanEmail = 'newuser@example.com';

        final requestId = await endpoints.emailIdp.startRegistration(
          sessionBuilder,
          email: rawEmail,
        );
        expect(requestId, isNotNull);

        final request = await EmailAccountRequest.db.findFirstRow(
          session,
          where: (t) => t.email.equals(cleanEmail),
        );
        expect(request, isNotNull);
        expect(request?.email, equals(cleanEmail));
      },
    );

    test('disposable and malformed emails are rejected', () async {
      await expectLater(
        endpoints.emailIdp.startRegistration(
          sessionBuilder,
          email: 'user@mailinator.com',
        ),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('not supported'),
          ),
        ),
      );

      await expectLater(
        endpoints.emailIdp.startRegistration(
          sessionBuilder,
          email: 'not-an-email',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test(
      'pending unverified registration request is updated on restart',
      () async {
        final session = sessionBuilder.build();
        const email = 'pending@example.com';

        final req1 = await endpoints.emailIdp.startRegistration(
          sessionBuilder,
          email: email,
        );
        expect(req1, isNotNull);

        final countAfterFirst = await EmailAccountRequest.db.count(
          session,
          where: (t) => t.email.equals(email),
        );
        expect(countAfterFirst, equals(1));

        final req2 = await endpoints.emailIdp.startRegistration(
          sessionBuilder,
          email: email,
        );
        expect(req2, isNotNull);

        final countAfterSecond = await EmailAccountRequest.db.count(
          session,
          where: (t) => t.email.equals(email),
        );
        expect(countAfterSecond, equals(1));
      },
    );

    test(
      'startPasswordReset for unknown email throws unknown account error',
      () async {
        await expectLater(
          endpoints.emailIdp.startPasswordReset(
            sessionBuilder,
            email: 'unknown@example.com',
          ),
          throwsA(isA<EmailAccountPasswordResetException>()),
        );
      },
    );
  });
}
