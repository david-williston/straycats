import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:straycats/src/features/auth/data/fake_auth_repository.dart';
import 'package:straycats/src/features/cats/domain/cat.dart';
import 'package:straycats/src/features/cats/domain/encounter.dart';
import 'package:straycats/src/features/cats/presentation/cat_card.dart';
import 'package:straycats/src/features/places/domain/coarse_area.dart';
import 'package:straycats/src/features/places/domain/place.dart';
import 'package:straycats/src/features/places/presentation/place_map.dart';
import 'package:straycats/src/features/share/data/card_image.dart';
import 'package:straycats/src/features/share/data/card_sharer.dart';
import 'package:straycats/src/features/share/presentation/share_card.dart';
import 'package:straycats/src/features/share/presentation/share_card_page.dart';
import 'package:straycats/src/localization/app_localizations.dart';

import '../../helpers.dart';

/// A tile that is still loading when the patience runs out.
class _NeverTiles extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) =>
      _Tile((_) => Completer<ImageInfo>().future);
}

/// A tile that cannot be fetched (offline).
class _FailingTiles extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) =>
      _Tile((_) => Future<ImageInfo>.error(const SocketException('offline')));
}

class _Tile extends ImageProvider<_Tile> {
  _Tile(this.load);
  final Future<ImageInfo> Function(_Tile) load;

  @override
  Future<_Tile> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(_Tile key, ImageDecoderCallback decode) =>
      OneFrameImageStreamCompleter(load(key));
}

class _FakeSharer extends CardSharer {
  final shared = <Uint8List>[];

  @override
  Future<File> share(Uint8List png) async {
    shared.add(png);
    return File('/cache/cat-card-1.png');
  }
}

ShareCardData _data({
  String name = 'Mountain Lion',
  String? neighbourhood = 'Roma Norte',
}) => ShareCardData(
  name: name,
  photo: File('/cats/1.jpg'),
  firstMet: DateTime(2026, 3, 9),
  neighbourhood: neighbourhood,
  area: neighbourhood == null ? null : CoarseArea.fromGeohash('9g3qrj'),
);

Future<void> _pumpCard(
  WidgetTester tester,
  ShareCardData data, {
  Locale locale = const Locale('en'),
  bool showMap = true,
}) async {
  tester.view.physicalSize = const Size(1080, 1350);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: RepaintBoundary(
          child: ShareCard(
            data: data,
            showMap: showMap,
            tileProvider: _NeverTiles(),
          ),
        ),
      ),
    ),
  );
}

Future<void> _pumpPage(
  WidgetTester tester, {
  required _FakeSharer sharer,
  TileProvider? tiles,
  ShareCardData? data,
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [cardSharerProvider.overrideWithValue(sharer)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ShareCardPage(
          data: data ?? _data(),
          tileProvider: tiles,
          render: (_) async => Uint8List.fromList([1, 2, 3]),
        ),
      ),
    ),
  );
}

void main() {
  group('the card', () {
    testWidgets('shows name, area, date and branding in English', (
      tester,
    ) async {
      await _pumpCard(tester, _data());
      expect(find.text('Mountain Lion'), findsOneWidget);
      expect(find.text('Seen around Roma Norte'), findsOneWidget);
      expect(find.text('Known since March 9, 2026'), findsOneWidget);
      expect(find.text('StrayCats'), findsOneWidget);
      expect(find.text('straycats.love'), findsOneWidget);
      expect(find.byType(PlaceMap), findsOneWidget);
    });

    testWidgets('speaks Spanish when the app does', (tester) async {
      await _pumpCard(tester, _data(), locale: const Locale('es'));
      expect(find.text('Visto por Roma Norte'), findsOneWidget);
      expect(find.textContaining('Conocido desde el 9 de marzo'), findsOne);
      expect(find.text('Mountain Lion'), findsOneWidget);
    });

    testWidgets('has no map and no place line without a neighbourhood', (
      tester,
    ) async {
      await _pumpCard(tester, _data(neighbourhood: null));
      expect(find.byType(PlaceMap), findsNothing);
      expect(find.textContaining('Seen around'), findsNothing);
      expect(find.text('Known since March 9, 2026'), findsOneWidget);
    });

    testWidgets('says the cat has no name yet, in both languages', (
      tester,
    ) async {
      await _pumpCard(tester, _data(name: '  '));
      expect(find.text('A cat with no name yet'), findsOneWidget);
      await _pumpCard(tester, _data(name: ''), locale: const Locale('es'));
      await tester.pump();
      expect(find.text('Un gato sin nombre todavía'), findsOneWidget);
    });

    testWidgets('shows no counts or rankings', (tester) async {
      await _pumpCard(tester, _data());
      expect(find.textContaining(RegExp(r'\d+ (times|veces)')), findsNothing);
    });

    testWidgets('can be left without its map', (tester) async {
      await _pumpCard(tester, _data(), showMap: false);
      expect(find.byType(PlaceMap), findsNothing);
      expect(find.text('Seen around Roma Norte'), findsOneWidget);
    });
  });

  group('sharing', () {
    testWidgets('a map that cannot load is dropped and the card still goes', (
      tester,
    ) async {
      final sharer = _FakeSharer();
      await _pumpPage(tester, sharer: sharer, tiles: _FailingTiles());
      await tester.pump();
      await tester.tap(find.text('Share'));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      expect(find.byType(PlaceMap), findsNothing);
      await tester.pump(const Duration(seconds: 1));
      expect(sharer.shared, hasLength(1));
    });

    testWidgets('a map that is too slow is dropped after about 3 s', (
      tester,
    ) async {
      final sharer = _FakeSharer();
      await _pumpPage(tester, sharer: sharer, tiles: _NeverTiles());
      await tester.tap(find.text('Share'));
      await tester.pump(const Duration(seconds: 2));
      expect(sharer.shared, isEmpty);
      expect(find.byType(PlaceMap), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();
      expect(find.byType(PlaceMap), findsNothing);
      expect(sharer.shared, hasLength(1));
      expect(find.text('Share'), findsOneWidget);
    });

    testWidgets('a card with no place shares at once', (tester) async {
      final sharer = _FakeSharer();
      await _pumpPage(tester, sharer: sharer, data: _data(neighbourhood: null));
      await tester.tap(find.text('Share'));
      await tester.pump();
      await tester.pump();
      expect(sharer.shared, hasLength(1));
    });
  });

  group('the image', () {
    testWidgets('is a PNG with no metadata chunks', (tester) async {
      await _pumpCard(tester, _data(neighbourhood: null));
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byType(RepaintBoundary).first,
      );
      final png = (await tester.runAsync(() => renderCardPng(boundary)))!;
      expect(png.sublist(0, 8), [137, 80, 78, 71, 13, 10, 26, 10]);
      final types = pngChunkTypes(png);
      expect(types.first, 'IHDR');
      expect(types.last, 'IEND');
      expect(types, everyElement(isIn({'IHDR', 'IDAT', 'IEND'})));
      final text = String.fromCharCodes(png);
      for (final marker in ['Exif', 'eXIf', 'GPS', 'tEXt', 'iTXt', 'XML']) {
        expect(text.contains(marker), isFalse, reason: marker);
      }
    });

    test('stripping removes EXIF, text and profile chunks', () {
      Uint8List chunk(String type, List<int> data) {
        final b = BytesBuilder();
        b.add((ByteData(4)..setUint32(0, data.length)).buffer.asUint8List());
        b.add(type.codeUnits);
        b.add(data);
        b.add([0, 0, 0, 0]); // CRC, not checked
        return b.toBytes();
      }

      final png = BytesBuilder()
        ..add([137, 80, 78, 71, 13, 10, 26, 10])
        ..add(chunk('IHDR', List.filled(13, 0)))
        ..add(chunk('eXIf', 'GPSLatitude'.codeUnits))
        ..add(chunk('tEXt', 'Comment\x00hi'.codeUnits))
        ..add(chunk('iCCP', [1, 2]))
        ..add(chunk('IDAT', [9, 9]))
        ..add(chunk('IEND', []));
      final clean = stripPngMetadata(png.toBytes());
      expect(pngChunkTypes(clean), ['IHDR', 'IDAT', 'IEND']);
      expect(String.fromCharCodes(clean).contains('GPS'), isFalse);
    });
  });

  group('the file', () {
    late Directory dir;
    setUp(() => dir = Directory.systemTemp.createTempSync('cards'));
    tearDown(() => dir.deleteSync(recursive: true));

    test(
      'is written to the cache folder, old cards deleted, then shared',
      () async {
        File('${dir.path}/cat-card-1.png').writeAsBytesSync([1]);
        File('${dir.path}/other.txt').writeAsBytesSync([1]);
        String? sent;
        final sharer = CardSharer(
          cacheDir: () async => dir,
          send: (path) async => sent = path,
          now: () => DateTime.fromMillisecondsSinceEpoch(2),
        );
        final file = await sharer.share(Uint8List.fromList([7, 7]));
        expect(sent, file.path);
        expect(file.path, '${dir.path}/cat-card-2.png');
        expect(file.readAsBytesSync(), [7, 7]);
        expect(File('${dir.path}/cat-card-1.png').existsSync(), isFalse);
        expect(File('${dir.path}/other.txt').existsSync(), isTrue);
      },
    );
  });

  group('on the cat card', () {
    Future<void> pumpCatCard(WidgetTester tester, {String? ownerUid}) async {
      final c = Cat(
        id: '1',
        name: 'Güero',
        encounters: [
          Encounter(
            id: 'a',
            photoId: '1',
            time: DateTime(2026, 1, 1),
            place: Place(
              area: CoarseArea.fromGeohash('9g3qrj'),
              neighbourhood: 'Roma Norte',
            ),
          ),
        ],
      );
      await tester.pumpWidget(
        ProviderScope(
          retry: (_, _) => null,
          overrides: fakeOverrides(
            db: FakeFirebaseFirestore(),
            auth: FakeAuthRepository(uid: 'test-uid'),
          ),
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: CatCard(cat: c, ownerUid: ownerUid),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
    }

    testWidgets('your own cat can be shared', (tester) async {
      await pumpCatCard(tester);
      expect(find.byTooltip('Share this cat'), findsOneWidget);
      await tester.tap(find.byTooltip('Share this cat'));
      await tester.pumpAndSettle();
      expect(find.byType(ShareCardPage), findsOneWidget);
    });

    testWidgets("an admin viewing someone else's cat cannot share", (
      tester,
    ) async {
      await pumpCatCard(tester, ownerUid: 'u1');
      expect(find.byTooltip('Share this cat'), findsNothing);
      expect(find.byIcon(Icons.ios_share), findsNothing);
    });
  });
}
