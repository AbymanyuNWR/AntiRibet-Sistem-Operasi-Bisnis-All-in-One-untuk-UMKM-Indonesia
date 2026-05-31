import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:antiribet/main.dart';

void main() {
  testWidgets('App renders without crash', (WidgetTester tester) async {
    await tester.pumpWidget(const AntiribetApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
