import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:straycats/cat.dart';
import 'package:straycats/cat_store.dart';
import 'package:straycats/main.dart';

/// Keeps cats in memory; the "camera" hands back [nextPhoto].
class FakeCatStore implements CatStore {
  FakeCatStore(this.cats);

  List<Cat> cats;
  List<Cat>? saved;
  File? nextPhoto = File('/cats/9000.jpg');
  final discarded = <File>[];

  @override
  Future<List<Cat>> load() async => cats;

  @override
  Future<void> save(List<Cat> cats) async =>
      saved = [for (final c in cats) Cat.fromJson(c.toJson())];

  @override
  Future<File?> takePhoto() async => nextPhoto;

  @override
  Future<void> discard(File photo) async => discarded.add(photo);

  @override
  File photoFile(String name) => File('/cats/$name');
}

Cat cat(String id, String name, List<int> times) => Cat(
  id: id,
  name: name,
  encounters: [
    for (final t in times)
      Encounter(
        id: '$t',
        photo: '$t.jpg',
        time: DateTime.fromMillisecondsSinceEpoch(t),
      ),
  ],
);

/// Shows the app on a phone-sized screen.
Future<void> pumpApp(WidgetTester tester, CatStore store) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(StrayCatsApp(store: store));
}

void main() {
  testWidgets('shows the title and empty state', (tester) async {
    await pumpApp(tester, FakeCatStore([]));
    await tester.pump();

    expect(find.text('Stray Cats'), findsOneWidget);
    expect(
      find.text('No cats yet. Tap the camera to meet one.'),
      findsOneWidget,
    );
  });

  testWidgets('shows one tile per cat and saves a new name', (tester) async {
    final store = FakeCatStore([
      cat('1', 'Ciccio', [1000, 3000]),
      cat('2', '', [2000]),
    ]);
    await pumpApp(tester, store);
    await tester.pump();

    expect(find.byType(CatTile), findsNWidgets(2));
    expect(find.text('Ciccio'), findsOneWidget);
    expect(find.text('No name yet'), findsOneWidget);

    await tester.tap(find.text('No name yet'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Ninja');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('Ninja'), findsOneWidget);
    expect(store.saved!.map((c) => c.name), ['Ciccio', 'Ninja']);
  });

  testWidgets('a new photo of an existing cat adds an encounter', (
    tester,
  ) async {
    final store = FakeCatStore([
      cat('1', 'Ciccio', [1000]),
      cat('2', 'Saibo', [2000]),
    ]);
    await pumpApp(tester, store);
    await tester.pump();

    await tester.tap(find.byTooltip('Meet a cat'));
    await tester.pumpAndSettle();

    expect(find.text('Who is this?'), findsOneWidget);
    expect(find.text('Is it one of these?'), findsOneWidget);
    expect(find.text('Ciccio'), findsOneWidget);
    expect(find.text('Saibo'), findsOneWidget);
    expect(find.text('New cat'), findsOneWidget);

    await tester.tap(find.text('Ciccio'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fed it'));
    await tester.pump();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('Stray Cats'), findsOneWidget);
    expect(find.byType(CatTile), findsNWidgets(2));
    final ciccio = store.saved!.firstWhere((c) => c.id == '1');
    expect(ciccio.encounters, hasLength(2));
    expect(ciccio.latest!.photo, '9000.jpg');
    expect(ciccio.latest!.type, EncounterType.fed);
    expect(store.discarded, isEmpty);
  });

  testWidgets('New cat creates a cat with its name', (tester) async {
    final store = FakeCatStore([
      cat('1', 'Ciccio', [1000]),
    ]);
    await pumpApp(tester, store);
    await tester.pump();

    await tester.tap(find.byTooltip('Meet a cat'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New cat'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), ' Ninja ');
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.byType(CatTile), findsNWidgets(2));
    expect(find.text('Ninja'), findsOneWidget);
    final ninja = store.saved!.firstWhere((c) => c.name == 'Ninja');
    expect(ninja.encounters.single.photo, '9000.jpg');
    expect(ninja.encounters.single.type, isNull);
  });

  testWidgets('backing out of Who is this? discards the photo', (tester) async {
    final store = FakeCatStore([
      cat('1', 'Ciccio', [1000]),
    ]);
    await pumpApp(tester, store);
    await tester.pump();

    await tester.tap(find.byTooltip('Meet a cat'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ciccio'));
    await tester.pumpAndSettle();
    await tester.pageBack(); // back to the choice of cat
    await tester.pumpAndSettle();
    expect(find.text('Is it one of these?'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(store.discarded.single.path, '/cats/9000.jpg');
    expect(store.saved, isNull);
  });
}
