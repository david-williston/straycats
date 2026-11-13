import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:straycats/src/features/settings/data/device_language_repository.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  DeviceLanguageRepository repo() =>
      DeviceLanguageRepository(SharedPreferencesAsync());

  test('has no choice at first', () async {
    expect(await repo().loadLocale(), isNull);
  });

  test('a saved choice is restored by a new repository', () async {
    await repo().saveLocale(const Locale('es'));
    expect(await repo().loadLocale(), const Locale('es'));
  });

  test('saving null goes back to the phone', () async {
    await repo().saveLocale(const Locale('es'));
    await repo().saveLocale(null);
    expect(await repo().loadLocale(), isNull);
  });
}
