import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calculator_app/main.dart';

void main() {
  testWidgets('Calculator starts at zero', (tester) async {
    await tester.pumpWidget(const CalculatorApp());

    expect(find.text('My Calculator'), findsOneWidget);
    expect(find.text('0'), findsWidgets);
  });
}