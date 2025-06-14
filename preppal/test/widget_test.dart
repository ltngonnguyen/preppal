// Basic Flutter widget test. WidgetTester performs interactions, finds child widgets, reads text, verifies properties.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:preppal/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build app, trigger frame.
    await tester.pumpWidget(const MyApp());

    // Verify counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap '+' icon, trigger frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify counter incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
