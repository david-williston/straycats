import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:straycats/src/features/cats/data/fake_cat_repository.dart';
import 'package:straycats/src/features/cats/data/fake_photo_repository.dart';
import 'package:straycats/src/features/cats/domain/cat.dart';
import 'package:straycats/src/features/cats/domain/encounter.dart';
import 'package:straycats/src/features/cats/domain/encounter_details.dart';

import '../../../helpers.dart';

Cat ciccio() => Cat(
  id: '1',
  name: 'Ciccio',
  encounters: [
    Encounter(
      id: '1000',
      photoId: '1000',
      time: DateTime.fromMillisecondsSinceEpoch(1000),
      details: const EncounterDetails(
        activity: Activity.sleeping,
        conditions: [Condition.thin],
        care: [Care.fed],
        note: 'Sleeps on the red car',
      ),
    ),
  ],
);

void main() {
  testWidgets('Who is this? has the sections, and Done works with nothing', (
    tester,
  ) async {
    final repo = FakeCatRepository([ciccio()]);
    await pumpApp(tester, cats: repo);

    await tester.tap(find.byTooltip('Meet a cat'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ciccio'));
    await tester.pumpAndSettle();

    expect(find.text('What was it doing?'), findsOneWidget);
    expect(find.text('How did it look?'), findsOneWidget);
    expect(find.text('Did you help?'), findsOneWidget);
    expect(find.text('Waiting at a door'), findsOneWidget);
    expect(find.text('Gave medicine'), findsOneWidget);
    expect(find.text('Its story (optional)'), findsOneWidget);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    final (_, e) = repo.addedEncounters.single;
    expect(e.details.isEmpty, isTrue);
  });

  testWidgets('the cat card shows each encounter\'s details and note', (
    tester,
  ) async {
    await pumpApp(tester, cats: FakeCatRepository([ciccio()]));
    await tester.tap(find.text('Ciccio'));
    await tester.pumpAndSettle();

    expect(find.text('Sleeping, Thin, Fed it'), findsOneWidget);
    expect(find.text('Sleeps on the red car'), findsOneWidget);
  });

  testWidgets('an old encounter with a type still shows', (tester) async {
    final old = Cat(
      id: '2',
      name: 'Saibo',
      encounters: [
        Encounter.fromJson({
          'id': '5',
          'photo': '5.jpg',
          'time': 5,
          'type': 'ear_tipped',
        }),
      ],
    );
    await pumpApp(tester, cats: FakeCatRepository([old]));
    await tester.tap(find.text('Saibo'));
    await tester.pumpAndSettle();

    expect(find.text('Ear tipped'), findsOneWidget);
  });

  testWidgets('tapping an encounter edits its details and note', (
    tester,
  ) async {
    final repo = FakeCatRepository([ciccio()]);
    await pumpApp(tester, cats: repo);
    await tester.tap(find.text('Ciccio'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sleeps on the red car'));
    await tester.pumpAndSettle();
    expect(find.text('Edit encounter'), findsOneWidget);

    await tester.tap(find.text('Gave water'));
    await tester.tap(find.text('Thin')); // unchoose
    await tester.enterText(
      find.widgetWithText(TextField, 'Its story (optional)'),
      'Now awake',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final (catId, e) = repo.updated.single;
    expect(catId, '1');
    expect(e.id, '1000');
    expect(e.details.activity, Activity.sleeping);
    expect(e.details.conditions, isEmpty);
    expect(e.details.care, [Care.fed, Care.gaveWater]);
    expect(e.details.note, 'Now awake');
    expect(find.text('Sleeping, Fed it, Gave water'), findsOneWidget);
    expect(find.text('Now awake'), findsOneWidget);
  });

  testWidgets('delete asks first, and the cat stays when it was the last', (
    tester,
  ) async {
    final repo = FakeCatRepository([ciccio()]);
    await pumpApp(tester, cats: repo);
    await tester.tap(find.text('Ciccio'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sleeps on the red car'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Delete this encounter?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(repo.deleted, isEmpty);

    await tester.tap(find.text('Sleeps on the red car'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Delete'),
      ),
    );
    await tester.pumpAndSettle();

    expect(repo.deleted, ['1000']);
    expect(find.text('Sleeps on the red car'), findsNothing);
    expect(repo.cats.single.name, 'Ciccio');
    expect(repo.cats.single.encounters, isEmpty);
  });

  testWidgets('everything reads in Spanish', (tester) async {
    final repo = FakeCatRepository([ciccio()]);
    await pumpApp(
      tester,
      cats: repo,
      photos: FakePhotoRepository(nextPhoto: File('/cats/9000.jpg')),
      locale: const Locale('es'),
    );
    await tester.tap(find.text('Ciccio'));
    await tester.pumpAndSettle();
    expect(find.text('Durmiendo, Muy delgado, Le di de comer'), findsOneWidget);

    await tester.tap(find.text('Sleeps on the red car'));
    await tester.pumpAndSettle();
    expect(find.text('Editar encuentro'), findsOneWidget);
    expect(find.text('¿Qué estaba haciendo?'), findsOneWidget);
    expect(find.text('¿Cómo se veía?'), findsOneWidget);
    expect(find.text('¿Lo ayudaste?'), findsOneWidget);
    expect(find.text('Su historia (opcional)'), findsOneWidget);

    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();
    expect(find.text('¿Eliminar este encuentro?'), findsOneWidget);
    expect(find.text('Cancelar'), findsOneWidget);
  });
}
