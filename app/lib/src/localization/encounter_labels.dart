import '../features/cats/domain/encounter_details.dart';
import 'app_localizations.dart';

extension ActivityLabel on Activity {
  /// The words shown for this activity in the current language.
  String label(AppLocalizations l10n) => switch (this) {
    Activity.eating => l10n.activityEating,
    Activity.sleeping => l10n.activitySleeping,
    Activity.resting => l10n.activityResting,
    Activity.waitingAtDoor => l10n.activityWaitingAtDoor,
    Activity.playing => l10n.activityPlaying,
    Activity.walkingBy => l10n.activityWalkingBy,
  };
}

extension ConditionLabel on Condition {
  String label(AppLocalizations l10n) => switch (this) {
    Condition.healthy => l10n.conditionHealthy,
    Condition.thin => l10n.conditionThin,
    Condition.limping => l10n.conditionLimping,
    Condition.unwellOrInjured => l10n.conditionUnwellOrInjured,
    Condition.withKittens => l10n.conditionWithKittens,
    Condition.earTipped => l10n.conditionEarTipped,
  };
}

extension CareLabel on Care {
  String label(AppLocalizations l10n) => switch (this) {
    Care.fed => l10n.careFed,
    Care.gaveWater => l10n.careGaveWater,
    Care.tookToVet => l10n.careTookToVet,
    Care.gaveMedicine => l10n.careGaveMedicine,
  };
}

extension EncounterDetailsSummary on EncounterDetails {
  /// The chosen activity, conditions and care as one line, or '' if none.
  String summary(AppLocalizations l10n) => [
    if (activity != null) activity!.label(l10n),
    for (final c in conditions) c.label(l10n),
    for (final c in care) c.label(l10n),
  ].join(', ');
}
