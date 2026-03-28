// Basic smoke test — full app boot requires SharedPreferences / GetX setup; see integration_test for E2E.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MaterialApp builds', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('SAHAMITHRA')),
        ),
      ),
    );
    expect(find.text('SAHAMITHRA'), findsOneWidget);
  });
}
