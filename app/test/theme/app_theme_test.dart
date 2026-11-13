import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:straycats/src/theme/app_theme.dart';

double _contrast(Color a, Color b) {
  final x = a.computeLuminance();
  final y = b.computeLuminance();
  return (x > y ? x + 0.05 : y + 0.05) / (x > y ? y + 0.05 : x + 0.05);
}

void main() {
  for (final entry in {'light': lightTheme(), 'dark': darkTheme()}.entries) {
    final theme = entry.value;
    final scheme = theme.colorScheme;

    testWidgets('the ${entry.key} theme builds', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            appBar: AppBar(title: const Text('StrayCats')),
            body: const Column(
              children: [
                TextField(),
                Chip(label: Text('Eating')),
                Card(child: Text('Cat')),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.photo_camera),
            ),
          ),
        ),
      );
      expect(find.text('StrayCats'), findsOneWidget);
      expect(theme.useMaterial3, isTrue);
      expect(theme.textTheme.bodyMedium?.fontFamily, 'Nunito');
    });

    test('the ${entry.key} text colours have 4.5:1 contrast', () {
      expect(_contrast(scheme.onSurface, scheme.surface), greaterThan(4.5));
      expect(
        _contrast(scheme.onSurfaceVariant, scheme.surface),
        greaterThan(4.5),
      );
      expect(
        _contrast(scheme.onSurfaceVariant, scheme.surfaceContainerLow),
        greaterThan(4.5),
      );
      expect(_contrast(scheme.primary, scheme.surface), greaterThan(4.5));
      expect(_contrast(scheme.onPrimary, scheme.primary), greaterThan(4.5));
      expect(
        _contrast(scheme.onSurface, scheme.surfaceContainerHighest),
        greaterThan(4.5),
      );
    });
  }
}
