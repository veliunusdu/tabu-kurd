// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application/main.dart';

void main() {
  testWidgets('TabuKurd app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TabuKurdApp());

    // Verify that the app starts with the correct title
    expect(find.text('TabuKurd (BêGotin)'), findsOneWidget);
    
    // Verify that we have basic navigation elements
    expect(find.byType(AppBar), findsOneWidget);
    
    // The test should complete without errors
  });
}
