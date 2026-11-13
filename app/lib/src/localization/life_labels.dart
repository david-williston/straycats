import 'package:flutter/material.dart';

import '../features/cats/domain/life_event.dart';
import 'app_localizations.dart';

/// "Passed away 16 Sep 2026", "Born around 2019": the sentence for [event],
/// with its date as precise as it was given, in [locale].
String lifeEventLabel(AppLocalizations l10n, LifeEvent event, String locale) {
  final kind = event.on.kind;
  final date = event.on.format(locale);
  return switch (event.type) {
    LifeEventType.born => l10n.lifeBorn(kind, date),
    LifeEventType.missing => l10n.lifeMissing(kind, date),
    LifeEventType.found => l10n.lifeFound(kind, date),
    LifeEventType.sterilised => l10n.lifeSterilised(kind, date),
    LifeEventType.died => l10n.lifeDied(kind, date),
  };
}

/// The short name of a type, for the "Add to story" choices and dialogs.
String lifeTypeName(AppLocalizations l10n, LifeEventType type) =>
    switch (type) {
      LifeEventType.born => l10n.storyAddBorn,
      LifeEventType.missing => l10n.storyAddMissing,
      LifeEventType.found => l10n.storyAddFound,
      LifeEventType.sterilised => l10n.storyAddSterilised,
      LifeEventType.died => l10n.storyAddDied,
    };

IconData lifeTypeIcon(LifeEventType type) => switch (type) {
  LifeEventType.born => Icons.cake_outlined,
  LifeEventType.missing => Icons.search,
  LifeEventType.found => Icons.home_outlined,
  LifeEventType.sterilised => Icons.medical_services_outlined,
  LifeEventType.died => Icons.favorite_border,
};
