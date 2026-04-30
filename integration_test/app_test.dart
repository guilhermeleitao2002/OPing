import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:oping/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('OPing integration tests', () {
    testWidgets('app launches and shows home screen', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('OPing'), findsOneWidget);
      expect(find.text('Latest Chapter'), findsOneWidget);
    });

    testWidgets('home screen shows chapter card or error state', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 10));

      final hasChapter = find.textContaining('Ch.').evaluate().isNotEmpty;
      final hasError = find.text('Retry').evaluate().isNotEmpty;
      expect(hasChapter || hasError, isTrue,
          reason: 'Should show a chapter card or an error/retry state');
    });

    testWidgets('background polling toggle is visible and interactive', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('Background polling'), findsOneWidget);

      final toggle = find.byType(Switch);
      expect(toggle, findsOneWidget);

      await tester.tap(toggle);
      await tester.pumpAndSettle();

      expect(find.text('Notifications paused'), findsOneWidget);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(find.text('Checks for new chapters every hour'), findsOneWidget);
    });

    testWidgets('Check Now button is present and tappable', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final checkNow = find.text('Check Now');
      expect(checkNow, findsOneWidget);

      await tester.tap(checkNow);
      await tester.pump();

      expect(find.text('Checking...'), findsOneWidget);

      await tester.pumpAndSettle(const Duration(seconds: 15));

      expect(find.text('Check Now'), findsOneWidget);
    });

    testWidgets('refresh icon button reloads data', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final refreshBtn = find.byIcon(Icons.refresh);
      expect(refreshBtn, findsOneWidget);

      await tester.tap(refreshBtn);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsWidgets);

      await tester.pumpAndSettle(const Duration(seconds: 10));
    });
  });
}
