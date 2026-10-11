import 'package:flutter_test/flutter_test.dart';
import 'package:promise_client/promise_client.dart';
import 'package:promise_flutter/screens/sign_in_screen.dart';

class FakeEndpointEmailIdp extends EndpointEmailIdp {
  FakeEndpointEmailIdp(super.caller);

  bool checkRegistrationResult = false;
  bool throwCheckError = false;
  bool throwStartError = false;
  int startRegistrationCalls = 0;
  void Function()? onStartRegistrationCalled;

  @override
  Future<bool> checkEmailRegistration({required String email}) async {
    if (throwCheckError) {
      throw Exception('SocketException: Connection refused');
    }
    return checkRegistrationResult;
  }

  @override
  Future<UuidValue> startRegistration({required String email}) async {
    startRegistrationCalls++;
    onStartRegistrationCalled?.call();
    if (throwStartError) {
      throw Exception('ServerpodClientException: Registration failed');
    }
    return UuidValue.fromString('11111111-1111-4111-a111-111111111111');
  }
}

class FakeClient extends Client {
  FakeClient(this.fakeEmailIdp) : super('http://localhost:8080/');

  final FakeEndpointEmailIdp fakeEmailIdp;

  @override
  EndpointEmailIdp get emailIdp => fakeEmailIdp;

  @override
  T getEndpointOfType<T extends EndpointRef>([String? name]) {
    if (fakeEmailIdp is T) {
      return fakeEmailIdp as T;
    }
    return super.getEndpointOfType<T>(name);
  }
}

void main() {
  group('SignInScreen Error Formatting Tests', () {
    test('transforms duplicate account exception to intended message', () {
      final error1 = ArgumentError(
        'An account with this email already exists. Please sign in instead.',
      );
      final msg1 = SignInScreen.cleanErrorMessage(error1);
      expect(
        msg1,
        equals(
          'An account with this email already exists. Please sign in instead.',
        ),
      );

      final error2 = Exception(
        'Failed to start registration: email already registered',
      );
      final msg2 = SignInScreen.cleanErrorMessage(error2);
      expect(
        msg2,
        equals(
          'An account with this email already exists. Please sign in instead.',
        ),
      );
    });

    test('transforms disposable email error to friendly message', () {
      final error = ArgumentError('This email provider is not supported.');
      final msg = SignInScreen.cleanErrorMessage(error);
      expect(
        msg,
        equals(
          'This email provider is not supported. Please use a permanent email address.',
        ),
      );
    });

    test(
      'preserves connection errors without misreporting duplicate account',
      () {
        final error = Exception('SocketException: Connection refused');
        final msg = SignInScreen.cleanErrorMessage(error);
        expect(
          msg,
          equals(
            'Unable to connect to Promise. Please check your connection and try again.',
          ),
        );
      },
    );

    test('preserves invalid credentials error for login', () {
      final error = Exception('EmailAccountLoginException: invalidCredentials');
      final msg = SignInScreen.cleanErrorMessage(error);
      expect(msg, equals('Incorrect email or password.'));
    });
  });

  group('PromiseEmailAuthController Flow Tests', () {
    late FakeEndpointEmailIdp fakeEmailIdp;
    late FakeClient fakeClient;

    setUp(() {
      final dummyCaller = Client('http://localhost:8080/');
      fakeEmailIdp = FakeEndpointEmailIdp(dummyCaller);
      fakeClient = FakeClient(fakeEmailIdp);
    });

    test(
      'when pre-check returns true, startRegistration is bypassed and duplicate error triggered',
      () async {
        fakeEmailIdp.checkRegistrationResult = true;
        Object? reportedError;

        final controller = PromiseEmailAuthController(
          client: fakeClient,
          onError: (error) => reportedError = error,
        );
        controller.emailController.text = 'existing@example.com';

        await controller.startRegistration();

        expect(fakeEmailIdp.startRegistrationCalls, equals(0));
        expect(reportedError, isNotNull);
        expect(
          SignInScreen.cleanErrorMessage(reportedError!),
          equals(
            'An account with this email already exists. Please sign in instead.',
          ),
        );
      },
    );

    test(
      'when pre-check returns false, startRegistration proceeds to server RPC',
      () async {
        fakeEmailIdp.checkRegistrationResult = false;
        Object? reportedError;

        final controller = PromiseEmailAuthController(
          client: fakeClient,
          onError: (error) => reportedError = error,
        );
        controller.emailController.text = 'brandnew@example.com';

        await controller.startRegistration();

        expect(fakeEmailIdp.startRegistrationCalls, equals(1));
        expect(reportedError, isNull);
      },
    );

    test(
      'when pre-check fails with network error, connection error is reported without claiming account exists',
      () async {
        fakeEmailIdp.throwCheckError = true;
        Object? reportedError;

        final controller = PromiseEmailAuthController(
          client: fakeClient,
          onError: (error) => reportedError = error,
        );
        controller.emailController.text = 'newuser@example.com';

        await controller.startRegistration();

        expect(fakeEmailIdp.startRegistrationCalls, equals(0));
        expect(reportedError, isNotNull);
        expect(
          SignInScreen.cleanErrorMessage(reportedError!),
          equals(
            'Unable to connect to Promise. Please check your connection and try again.',
          ),
        );
      },
    );

    test(
      'when pre-check returns false but startRegistration fails due to race, follow-up check detects duplicate',
      () async {
        fakeEmailIdp.checkRegistrationResult = false;
        fakeEmailIdp.throwStartError = true;
        Object? reportedError;

        final controller = PromiseEmailAuthController(
          client: fakeClient,
          onError: (error) {
            reportedError = error;
          },
        );
        controller.emailController.text = 'concurrent@example.com';

        fakeEmailIdp.onStartRegistrationCalled = () {
          fakeEmailIdp.checkRegistrationResult = true;
        };

        await controller.startRegistration();

        expect(fakeEmailIdp.startRegistrationCalls, equals(1));
        expect(reportedError, isNotNull);
        expect(
          SignInScreen.cleanErrorMessage(reportedError!),
          equals(
            'An account with this email already exists. Please sign in instead.',
          ),
        );
      },
    );
  });
}
