import '../features/cats/domain/encounter_type.dart';
import 'app_localizations.dart';

extension EncounterTypeLabel on EncounterType {
  /// The words shown for this type in the current language.
  String label(AppLocalizations l10n) => switch (this) {
    EncounterType.seen => l10n.encounterSeen,
    EncounterType.fed => l10n.encounterFed,
    EncounterType.unwell => l10n.encounterUnwell,
    EncounterType.kittens => l10n.encounterKittens,
    EncounterType.earTipped => l10n.encounterEarTipped,
  };
}
