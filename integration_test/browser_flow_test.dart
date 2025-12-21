import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wealthbridge/browser/browser_shell.dart';
import 'package:wealthbridge/browser/browser_storage.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('navigates and responds to permission prompts', (tester) async {
    final storage = InMemoryBrowserStorage();

    await tester.pumpWidget(
      MaterialApp(
        home: BrowserShell(
          embedWebView: false,
          storageManager: storage,
        ),
      ),
    );

    await tester.tap(find.text('Simulate load'));
    await tester.pumpAndSettle();
    expect(storage.visits.length, greaterThanOrEqualTo(1));

    await tester.tap(find.text('Simulate permission'));
    await tester.pumpAndSettle();

    expect(find.text('Permission request'), findsOneWidget);
    await tester.tap(find.text('Allow'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Permission request'), findsNothing);
  });
}
