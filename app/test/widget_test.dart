import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:straycats/main.dart';

void main() {
  testWidgets('shows the title and empty state', (tester) async {
    await tester.pumpWidget(
      StrayCatsApp(
        load: () async => [],
        capture: () async {},
        loadNames: () async => {},
        saveNames: (_) async {},
      ),
    );
    await tester.pump();

    expect(find.text('Stray Cats'), findsOneWidget);
    expect(
      find.text('No cats yet. Tap the camera to meet one.'),
      findsOneWidget,
    );
  });

  testWidgets('shows names under photos and saves a new one', (tester) async {
    Map<String, String>? saved;
    await tester.pumpWidget(
      StrayCatsApp(
        load: () async => [File('/cats/2.jpg'), File('/cats/1.jpg')],
        capture: () async {},
        loadNames: () async => {'2.jpg': 'Whiskers'},
        saveNames: (names) async => saved = Map.of(names),
      ),
    );
    await tester.pump();

    expect(find.text('Whiskers'), findsOneWidget);
    expect(find.text('No name yet'), findsOneWidget);

    await tester.tap(find.text('No name yet'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Mittens');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('Mittens'), findsOneWidget);
    expect(saved, {'2.jpg': 'Whiskers', '1.jpg': 'Mittens'});

    await tester.tap(find.text('Whiskers'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '');
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Whiskers'), findsNothing);
    expect(saved, {'1.jpg': 'Mittens'});
  });
}
