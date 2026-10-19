import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../screens/sign_in_screen.dart';

/// Clean, privacy-first OTP verification code input widget for Promise.
///
/// Passes `onClipboardFound: null` to Pinput so that automatic background
/// clipboard reads are 100% eliminated at the widget boundary.
///
/// Provides an explicit, user-triggered "Paste Code from Clipboard" button that
/// invokes the clipboard API ONLY when explicitly tapped by the user.
class PromiseVerificationCodeInput extends StatefulWidget {
  final TextEditingController verificationCodeController;
  final VoidCallback onCompleted;
  final bool isLoading;
  final int length;
  final TextInputType keyboardType;
  final FocusNode? focusNode;

  const PromiseVerificationCodeInput({
    required this.onCompleted,
    required this.verificationCodeController,
    required this.isLoading,
    this.length = 8,
    this.keyboardType = TextInputType.number,
    this.focusNode,
    super.key,
  });

  @override
  State<PromiseVerificationCodeInput> createState() =>
      _PromiseVerificationCodeInputState();
}

class _PromiseVerificationCodeInputState
    extends State<PromiseVerificationCodeInput> {
  Future<void> _pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData('text/plain');
    final text = clipboardData?.text?.trim();
    if (text != null && text.isNotEmpty) {
      widget.verificationCodeController.text = text;
      if (text.length == widget.length) {
        widget.onCompleted();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = constraints.maxWidth / widget.length;

            return Container(
              height: math.max(itemWidth, 48),
              alignment: Alignment.center,
              child: Pinput(
                controller: widget.verificationCodeController,
                length: widget.length,
                showCursor: false,
                enableInteractiveSelection: true,
                keyboardType: widget.keyboardType,
                // CRITICAL PRIVACY FIX: onClipboardFound is set to NULL!
                // This guarantees Pinput never calls Clipboard.getData() on load, rebuild, or focus!
                onClipboardFound: null,
                autofocus: true,
                enabled: !widget.isLoading,
                focusNode: widget.focusNode,
                onCompleted: (_) => widget.onCompleted(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        // Explicit, user-triggered Paste Code action
        TextButton.icon(
          onPressed: widget.isLoading ? null : _pasteFromClipboard,
          icon: const Icon(Icons.content_paste, size: 16),
          label: const Text('Paste Code from Clipboard'),
        ),
      ],
    );
  }
}

/// Custom verification form replacing Serverpod Auth IDP's default form to eliminate
/// automatic clipboard reads.
class PromiseVerificationForm extends StatefulWidget {
  final String title;
  final PromiseEmailAuthController controller;
  final VoidCallback onCompleted;

  const PromiseVerificationForm({
    super.key,
    required this.title,
    required this.controller,
    required this.onCompleted,
  });

  @override
  State<PromiseVerificationForm> createState() =>
      _PromiseVerificationFormState();
}

class _PromiseVerificationFormState extends State<PromiseVerificationForm> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = widget.controller;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the verification code sent to your email address.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        PromiseVerificationCodeInput(
          focusNode: _focusNode,
          verificationCodeController: controller.verificationCodeController,
          onCompleted: widget.onCompleted,
          isLoading: controller.isLoading,
          length: 8,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: controller.isLoading ? null : widget.onCompleted,
          child: controller.isLoading
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : const Text('Verify Code'),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: controller.isLoading
              ? null
              : () => controller.navigateTo(EmailFlowScreen.login),
          child: const Text('Back to Sign In'),
        ),
      ],
    );
  }
}
