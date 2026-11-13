import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../localization/app_localizations.dart';
import '../domain/language_names.dart';
import 'language_controller.dart';

/// The app bar button that opens the language dialog.
class LanguageButton extends StatelessWidget {
  const LanguageButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.translate),
      tooltip: AppLocalizations.of(context).language,
      onPressed: () => showDialog<void>(
        context: context,
        builder: (_) => const LanguageDialog(),
      ),
    );
  }
}

/// Radio choices: the phone's language, then each supported language by its
/// own name. Choosing one applies it and closes the dialog.
class LanguageDialog extends ConsumerWidget {
  const LanguageDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final chosen = ref.watch(languageControllerProvider).value;
    final controller = ref.read(languageControllerProvider.notifier);
    void choose(Locale? locale) {
      controller.choose(locale);
      Navigator.of(context).pop();
    }

    return AlertDialog(
      title: Text(l10n.language),
      content: RadioGroup<Locale?>(
        groupValue: chosen,
        onChanged: choose,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<Locale?>(
              value: null,
              title: Text(l10n.phoneLanguage),
            ),
            for (final locale in AppLocalizations.supportedLocales)
              RadioListTile<Locale?>(
                value: locale,
                title: Text(
                  languageNames[locale.languageCode] ?? locale.languageCode,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
