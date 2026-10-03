import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
// ignore: implementation_imports
import 'package:serverpod_auth_idp_flutter/src/common/exceptions.dart';
import '../client.dart';
import '../utils/disposable_email_validator.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  String _cleanErrorMessage(Object error) {
    final buffer = StringBuffer(error.toString());

    if (error is UserFacingException) {
      if (error.originalException != null) {
        buffer.write(' ');
        buffer.write(error.originalException.toString());
      }
    }

    final fullStr = buffer.toString();

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
        return 'That verification code is incorrect. Please try again.';
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    void handleError(Object error) {
      final cleanMsg = _cleanErrorMessage(error);
      debugPrint('[SignInScreen] Error caught: $error -> $cleanMsg');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cleanMsg),
          behavior: SnackBarBehavior.floating,
          backgroundColor: theme.colorScheme.error,
        ),
      );
    }

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
                SignInWidget(
                  client: client,
                  emailSignInWidget: EmailSignInWidget(
                    client: client,
                    onError: handleError,
                    onAuthenticated: () {},
                    emailValidation: (email) {
                      try {
                        DisposableEmailValidator.validateAndNormalize(email);
                      } on ArgumentError catch (e) {
                        throw InvalidEmailException(
                          e.message?.toString() ?? 'Invalid email',
                        );
                      }
                    },
                  ),
                  onAuthenticated: () {},
                  onError: handleError,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
