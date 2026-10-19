import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promise_flutter/widgets/promise_verification_code_input.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PromiseVerificationCodeInput Widget Behavioral & Privacy Tests', () {
    late int clipboardGetDataCallCount;

    setUp(() {
      clipboardGetDataCallCount = 0;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.getData') {
          clipboardGetDataCallCount++;
          return <String, dynamic>{
            'text': '87654321',
          };
        }
        return null;
      });
    });

    testWidgets(
      '1. Rendering PromiseVerificationCodeInput does NOT call Clipboard.getData',
          (tester) async {
        final controller = TextEditingController();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PromiseVerificationCodeInput(
                verificationCodeController: controller,
                onCompleted: () {},
                isLoading: false,
                length: 8,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Zero background clipboard reads on render
        expect(clipboardGetDataCallCount, equals(0));
        expect(controller.text, isEmpty);
      },
    );

    testWidgets(
      '2. Focusing and rebuilding PromiseVerificationCodeInput does NOT trigger clipboard reads',
          (tester) async {
        final controller = TextEditingController();
        final focusNode = FocusNode();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PromiseVerificationCodeInput(
                focusNode: focusNode,
                verificationCodeController: controller,
                onCompleted: () {},
                isLoading: false,
                length: 8,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(clipboardGetDataCallCount, equals(0));

        // Request focus
        focusNode.requestFocus();
        await tester.pumpAndSettle();

        // Zero clipboard reads on focus or rebuild
        expect(clipboardGetDataCallCount, equals(0));
        expect(controller.text, isEmpty);
      },
    );

    testWidgets(
      '3. Typing a verification code manually works and triggers onCompleted',
          (tester) async {
        final controller = TextEditingController();
        bool completed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PromiseVerificationCodeInput(
                verificationCodeController: controller,
                onCompleted: () => completed = true,
                isLoading: false,
                length: 8,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Simulate typing 8-digit OTP manually
        controller.text = '12345678';
        await tester.pumpAndSettle();

        expect(clipboardGetDataCallCount, equals(0));
        expect(controller.text, equals('12345678'));
        expect(completed, isTrue);
      },
    );

    testWidgets(
      '4. Clipboard access occurs ONLY after user taps explicit "Paste Code" button',
          (tester) async {
        final controller = TextEditingController();
        bool completed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PromiseVerificationCodeInput(
                verificationCodeController: controller,
                onCompleted: () => completed = true,
                isLoading: false,
                length: 8,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Zero clipboard reads before user action
        expect(clipboardGetDataCallCount, equals(0));

        // Tap explicit "Paste Code from Clipboard" button
        final pasteButton = find.text('Paste Code from Clipboard');
        expect(pasteButton, findsOneWidget);
        await tester.tap(pasteButton);
        await tester.pumpAndSettle();

        // Clipboard was accessed exactly ONCE after explicit user tap
        expect(clipboardGetDataCallCount, equals(1));
        expect(controller.text, equals('87654321'));
        expect(completed, isTrue);
      },
    );
  });
}
