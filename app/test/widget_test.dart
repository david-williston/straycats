import 'package:flutter_test/flutter_test.dart';
import 'package:straycats/main.dart';

void main() {
  testWidgets('shows the title and empty state', (tester) async {
    await tester.pumpWidget(
      StrayCatsApp(load: () async => [], capture: () async {}),
    );
    await tester.pump();

    expect(find.text('Stray Cats'), findsOneWidget);
    expect(find.text('No cats yet. Tap the camera to meet one.'), findsOneWidget);
  });
}
