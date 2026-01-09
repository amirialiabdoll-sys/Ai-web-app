import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easymemo/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const EasyMemoApp());
    expect(find.text('EasyMemo'), findsOneWidget);
  });
}
