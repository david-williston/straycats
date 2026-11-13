import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:straycats/src/features/cats/application/matching_service.dart';

import '../../../helpers.dart';

void main() {
  test('the stub offers every cat, most recently seen first', () {
    final a = cat('1', 'A', [1000]);
    final b = cat('2', 'B', [2000]);
    expect(MatchingService().findMatches(File('/cats/9.jpg'), [a, b]), [b, a]);
  });
}
