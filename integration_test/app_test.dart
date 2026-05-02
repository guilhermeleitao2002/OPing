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
      expect(find.text('Tracked manga'), findsOneWidget);
    });

    testWidgets('home screen shows tracked-manga list or empty state',
        (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 10));

      final hasTrackedItem = find.textContaining('Last seen').evaluate().isNotEmpty;
      final hasEmptyState = find.text('No manga tracked yet').evaluate().isNotEmpty;
      expect(hasTrackedItem || hasEmptyState, isTrue,
          reason: 'Should show a tracked manga or the empty state');
    });

    testWidgets('background polling toggle is visible and interactive',
        (tester) async {
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

    testWidgets('Add manga FAB is present and opens search screen',
        (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final addBtn = find.text('Add manga');
      expect(addBtn, findsOneWidget);

      await tester.tap(addBtn);
      await tester.pumpAndSettle();

      expect(find.text('Search MangaDex by title'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('Tracked manga'), findsOneWidget);
    });

    testWidgets('refresh icon button reloads data', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final refreshBtn = find.byIcon(Icons.refresh);
      expect(refreshBtn, findsOneWidget);

      await tester.tap(refreshBtn);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      expect(find.text('Tracked manga'), findsOneWidget);
    });
  });
}
