import 'package:flutter_test/flutter_test.dart';

import 'package:oping/main.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const OPingApp());
    expect(find.text('OPing'), findsOneWidget);
  });
}
