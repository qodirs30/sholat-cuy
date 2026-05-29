import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sholat_cuy/src/presentation/widgets/frosted_card.dart';

void main() {
  testWidgets('FrostedCard renders child widget correctly', (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FrostedCard(
            child: Text('Test Child Text'),
          ),
        ),
      ),
    );

    // Verify the child widget is found
    expect(find.text('Test Child Text'), findsOneWidget);
    
    // Verify that the FrostedCard container/BackdropFilter exists
    expect(find.byType(BackdropFilter), findsOneWidget);
  });
}
