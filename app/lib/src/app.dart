import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/settings/presentation/language_controller.dart';
import 'features/startup/presentation/app_startup_widget.dart';
import 'localization/app_localizations.dart';
import 'theme/app_theme.dart';

class StrayCatsApp extends ConsumerWidget {
  const StrayCatsApp({super.key, this.locale});

  /// Overrides the chosen language (for tests); null uses the user's choice,
  /// which follows the phone until they pick one.
  final Locale? locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      locale: locale ?? ref.watch(languageControllerProvider).value,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: lightTheme(),
      darkTheme: darkTheme(),
      themeMode: ThemeMode.system,
      home: const AppStartupWidget(),
    );
  }
}
