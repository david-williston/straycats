import 'package:flutter/material.dart';

import 'features/cats/presentation/cats_page.dart';
import 'localization/app_localizations.dart';

class StrayCatsApp extends StatelessWidget {
  const StrayCatsApp({super.key, this.locale});

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
      home: const CatsPage(),
    );
  }
}
