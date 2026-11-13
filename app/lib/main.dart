import 'package:flutter/material.dart';

import 'cat_store.dart';
import 'l10n/app_localizations.dart';
import 'screens/cats_page.dart';

void main() => runApp(StrayCatsApp(store: DeviceCatStore()));

class StrayCatsApp extends StatelessWidget {
  const StrayCatsApp({super.key, required this.store, this.locale});

  final CatStore store;

  /// Overrides the device language (for tests); null follows the device.
  final Locale? locale;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
      ),
      home: CatsPage(store: store),
    );
  }
}
