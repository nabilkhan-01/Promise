import 'package:promise_server/src/auth/disposable_email_validator.dart';
import 'package:test/test.dart';

void main() {
  group('Server-side Disposable Email Validation', () {
    test('valid Gmail email is normalized and accepted', () {
      final clean = DisposableEmailValidator.validateAndNormalize(
        '  TestUser@GMAIL.com  ',
      );
      expect(clean, equals('testuser@gmail.com'));
    });

    test('startRegistration with mailinator.com is rejected', () {
      expect(
        () => DisposableEmailValidator.validateAndNormalize(
          'user@mailinator.com',
        ),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('not supported'),
          ),
        ),
      );
    });

    test('startRegistration with tempmail.com is rejected', () {
      expect(
        () =>
            DisposableEmailValidator.validateAndNormalize('test@tempmail.com'),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('not supported'),
          ),
        ),
      );
    });

    test('malformed email addresses are rejected', () {
      expect(
        () => DisposableEmailValidator.validateAndNormalize('not-an-email'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('login with disposable domain is rejected', () {
      expect(
        () => DisposableEmailValidator.validateAndNormalize(
          'fake@guerrillamail.com',
        ),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('not supported'),
          ),
        ),
      );
    });

    test('startPasswordReset with disposable domain is rejected', () {
      expect(
        () =>
            DisposableEmailValidator.validateAndNormalize('user@temp-mail.org'),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('not supported'),
          ),
        ),
      );
    });
  });
}
