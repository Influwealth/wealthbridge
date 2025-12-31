import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wealthbridge/browser/browser_shell.dart';
import 'package:wealthbridge/browser/browser_storage.dart';

void main() {
  group('BrowserShell', () {
    testWidgets('renders tabs, address bar, and placeholder web surface',
        (tester) async {
      final storage = InMemoryBrowserStorage();

      await tester.pumpWidget(
        MaterialApp(
          home: BrowserShell(
            embedWebView: false,
            storageManager: storage,
          ),
        ),
      );

      expect(find.text('Embedded browser placeholder'), findsOneWidget);
      expect(find.byTooltip('New tab'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(storage.visits, isEmpty);

      await tester.enterText(find.byType(TextField), 'example.com');
      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Simulate load'));
      await tester.pumpAndSettle();

      expect(storage.visits, isNotEmpty);
      expect(find.byType(ChoiceChip), findsNWidgets(1));

      await tester.tap(find.byTooltip('New tab'));
      await tester.pumpAndSettle();

      expect(find.byType(ChoiceChip), findsNWidgets(2));
    });
  });
}
