import 'package:promise_server/src/auth/disposable_email_validator.dart';
import 'package:test/test.dart';

void main() {
  group('DisposableEmailValidator', () {
    test('accepts valid permanent email addresses', () {
      expect(
        DisposableEmailValidator.validateAndNormalize('user@gmail.com'),
        equals('user@gmail.com'),
      );
      expect(
        DisposableEmailValidator.validateAndNormalize('alice@outlook.com'),
        equals('alice@outlook.com'),
      );
      expect(
        DisposableEmailValidator.validateAndNormalize('student@university.edu'),
        equals('student@university.edu'),
      );
    });

    test('normalizes email addresses to lowercase and trims whitespace', () {
      expect(
        DisposableEmailValidator.validateAndNormalize('  Alice@Example.COM  '),
        equals('alice@example.com'),
      );
    });

    test('rejects disposable email domains', () {
      expect(
        () => DisposableEmailValidator.validateAndNormalize(
          'test@mailinator.com',
        ),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('not supported'),
          ),
        ),
      );

      expect(
        () =>
            DisposableEmailValidator.validateAndNormalize('user@tempmail.com'),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => DisposableEmailValidator.validateAndNormalize(
          'user@guerrillamail.com',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects malformed or empty email addresses', () {
      expect(
        () => DisposableEmailValidator.validateAndNormalize(''),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => DisposableEmailValidator.validateAndNormalize('invalid-email'),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => DisposableEmailValidator.validateAndNormalize('@no-user.com'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
