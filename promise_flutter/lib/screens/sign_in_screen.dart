import 'package:flutter/material.dart';
import 'package:promise_client/promise_client.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
// ignore: implementation_imports
import 'package:serverpod_auth_idp_flutter/src/common/exceptions.dart';
import '../client.dart';
import '../utils/disposable_email_validator.dart';
import '../widgets/promise_verification_code_input.dart';

class PromiseEmailAuthController extends EmailAuthController {
  PromiseEmailAuthController({
    required super.client,
    super.startScreen = EmailFlowScreen.startRegistration,
    super.onAuthenticated,
    super.onError,
    super.emailValidation,
  });

  @override
  Future<void> startRegistration() async {
    final email = emailController.text.trim();
    try {
      emailValidation.call(email);
    } catch (e) {
      onError?.call(e);
      return;
    }

    try {
      final promiseClient = this.client as Client;
      final isRegistered = await promiseClient.emailIdp.checkEmailRegistration(
        email: email,
      );
      if (isRegistered) {
        onError?.call(
          ArgumentError(
            'An account with this email already exists. Please sign in instead.',
          ),
        );
        return;
      }
    } catch (e) {
      if (e is ArgumentError &&
          (e.message.toString().contains('not supported') ||
              e.message.toString().contains('already exists'))) {
        onError?.call(e);
        return;
      }
      onError?.call(e);
      return;
    }

    await super.startRegistration();

    if (error != null) {
      try {
        final promiseClient = this.client as Client;
        final isNowRegistered = await promiseClient.emailIdp
            .checkEmailRegistration(email: email);
        if (isNowRegistered) {
          onError?.call(
            ArgumentError(
              'An account with this email already exists. Please sign in instead.',
            ),
          );
        }
      } catch (_) {}
    }
  }
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  static String cleanErrorMessage(Object error) {
    final buffer = StringBuffer(error.toString());

    if (error is UserFacingException) {
      if (error.originalException != null) {
        buffer.write(' ');
        buffer.write(error.originalException.toString());
      }
    }

    final fullStr = buffer.toString();

    // 0. Existing Account / Duplicate Sign Up
    if (fullStr.contains('already exists') ||
        fullStr.contains('already registered') ||
        fullStr.contains('EmailAccountAlreadyRegisteredException')) {
      return 'An account with this email already exists. Please sign in instead.';
    }

    // 1. Disposable Email
    if (fullStr.contains('disposable') || fullStr.contains('not supported')) {
      return 'This email provider is not supported. Please use a permanent email address.';
    }

    // 2. Login Errors (wrong email or password)
    if (fullStr.contains('EmailAccountLoginException') ||
        fullStr.contains('invalidCredentials') ||
        fullStr.contains('Invalid email or password')) {
      return 'Incorrect email or password.';
    }

    if (fullStr.contains('tooManyAttempts')) {
      return 'Too many login attempts. Please try again later.';
    }

    // 3. Password Reset / Account Not Found
    if (fullStr.contains('AccountNotFound')) {
      return 'No account found with this email address.';
    }

    // 4. Code Verification Errors & Password Reset Errors
    if (fullStr.contains('EmailAccountPasswordResetException') ||
        fullStr.contains('EmailAccountRequestException')) {
      if (fullStr.contains('unknown')) {
        return 'No account found with this email address.';
      }
      if (fullStr.contains('invalid')) {
        return 'That verification code is incorrect. Please check and try again.';
      }
      if (fullStr.contains('expired')) {
        return 'That verification code has expired. Please request a new code.';
      }
    }

    // 5. Brevo Delivery Errors
    if (fullStr.contains('BrevoDeliveryError')) {
      return 'We couldn\'t send the verification email. Please try again.';
    }

    // 6. Network / Connection Errors
    if (fullStr.contains('SocketException') ||
        fullStr.contains('Connection refused') ||
        fullStr.contains('ClientException')) {
      return 'Unable to connect to Promise. Please check your connection and try again.';
    }

    // Fallback if error has a readable message
    if (error is UserFacingException &&
        !error.message.contains('An error occurred while processing')) {
      return error.message;
    }

    if (error.toString().contains('ArgumentError:')) {
      return error.toString().replaceFirst('ArgumentError:', '').trim();
    }
    if (error.toString().contains('Exception:')) {
      return error.toString().replaceFirst('Exception:', '').trim();
    }

    return 'Authentication failed. Please check your details and connection.';
  }

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  late final PromiseEmailAuthController _emailAuthController;

  @override
  void initState() {
    super.initState();
    _emailAuthController = PromiseEmailAuthController(
      client: client,
      startScreen: EmailFlowScreen.startRegistration,
      onAuthenticated: () {},
      onError: _handleError,
      emailValidation: (email) {
        try {
          DisposableEmailValidator.validateAndNormalize(email);
        } on ArgumentError catch (e) {
          throw InvalidEmailException(
            e.message?.toString() ?? 'Invalid email',
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _emailAuthController.dispose();
    super.dispose();
  }

  void _handleError(Object error) async {
    var cleanMsg = SignInScreen.cleanErrorMessage(error);
    var fullStr = error.toString();
    var isDuplicateAccount =
        fullStr.contains('already exists') ||
        fullStr.contains('already registered') ||
        fullStr.contains('EmailAccountAlreadyRegisteredException');

    if (!isDuplicateAccount &&
        _emailAuthController.currentScreen ==
            EmailFlowScreen.startRegistration) {
      final email = _emailAuthController.emailController.text.trim();
      if (email.isNotEmpty) {
        try {
          final promiseClient = _emailAuthController.client as Client;
          final isNowRegistered = await promiseClient.emailIdp
              .checkEmailRegistration(email: email);
          if (isNowRegistered) {
            isDuplicateAccount = true;
            cleanMsg =
                'An account with this email already exists. Please sign in instead.';
          }
        } catch (_) {}
      }
    }

    if (!mounted) return;

    debugPrint('[SignInScreen] Error caught: $error -> $cleanMsg');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(cleanMsg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.error,
        action: isDuplicateAccount
            ? SnackBarAction(
                label: 'Sign In',
                textColor: Colors.white,
                onPressed: () {
                  _emailAuthController.navigateTo(EmailFlowScreen.login);
                },
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.handshake_outlined,
                  size: 72,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Promise',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Make commitments. Keep them accountable.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),
                ListenableBuilder(
                  listenable: _emailAuthController,
                  builder: (context, _) {
                    final screen = _emailAuthController.currentScreen;
                    if (screen == EmailFlowScreen.verifyRegistration ||
                        screen == EmailFlowScreen.verifyPasswordReset) {
                      final isPasswordReset =
                          screen == EmailFlowScreen.verifyPasswordReset;
                      final title = isPasswordReset
                          ? 'Verify Reset Code'
                          : 'Verify Account';

                      return PromiseVerificationForm(
                        title: title,
                        controller: _emailAuthController,
                        onCompleted: isPasswordReset
                            ? _emailAuthController.verifyPasswordResetCode
                            : _emailAuthController.verifyRegistrationCode,
                      );
                    }

                    return SignInWidget(
                      client: client,
                      emailSignInWidget: EmailSignInWidget(
                        controller: _emailAuthController,
                      ),
                      onAuthenticated: () {},
                      onError: _handleError,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
