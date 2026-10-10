import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promise_flutter/widgets/indicator_icon_button.dart';

void main() {
  group('IndicatorIconButton Widget Tests', () {
    testWidgets('renders normal icon and triggers onPressed callback', (
      WidgetTester tester,
    ) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IndicatorIconButton(
              onPressed: () => pressed = true,
              icon: const Icon(Icons.favorite_border),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);

      await tester.tap(find.byType(IndicatorIconButton));
      expect(pressed, isTrue);
    });

    testWidgets('renders optional label alongside icon', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IndicatorIconButton(
              onPressed: () {},
              icon: const Icon(Icons.thumb_up),
              label: const Text('Like'),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.thumb_up), findsOneWidget);
      expect(find.text('Like'), findsOneWidget);
    });

    testWidgets('renders selectedIcon when isSelected is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IndicatorIconButton(
              onPressed: () {},
              icon: const Icon(Icons.bookmark_border),
              selectedIcon: const Icon(Icons.bookmark),
              isSelected: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.bookmark), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_border), findsNothing);
    });

    testWidgets('displays loading indicator and disables interaction', (
      WidgetTester tester,
    ) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IndicatorIconButton(
              onPressed: () => pressed = true,
              icon: const Icon(Icons.cloud_upload),
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.cloud_upload), findsNothing);

      await tester.tap(find.byType(IndicatorIconButton));
      expect(pressed, isFalse);
    });

    testWidgets('displays success indicator and disables interaction', (
      WidgetTester tester,
    ) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IndicatorIconButton(
              onPressed: () => pressed = true,
              icon: const Icon(Icons.check),
              showSuccessIndicator: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check_circle), findsOneWidget);

      await tester.tap(find.byType(IndicatorIconButton));
      expect(pressed, isFalse);
    });

    testWidgets('animates transition between states', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return IndicatorIconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.star_border),
                  selectedIcon: const Icon(Icons.star),
                  isSelected: false,
                );
              },
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.star_border), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return IndicatorIconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.star_border),
                  selectedIcon: const Icon(Icons.star),
                  isSelected: true,
                );
              },
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 150));
      expect(find.byType(AnimatedSwitcher), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('renders custom indicator when provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IndicatorIconButton(
              onPressed: () {},
              icon: const Icon(Icons.refresh),
              isLoading: true,
              indicator: const Text('Loading...'),
            ),
          ),
        ),
      );

      expect(find.text('Loading...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('provides accessibility tooltip semantics', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IndicatorIconButton(
              onPressed: () {},
              icon: const Icon(Icons.info),
              tooltip: 'Information',
            ),
          ),
        ),
      );

      expect(find.byTooltip('Information'), findsOneWidget);
    });
  });
}
