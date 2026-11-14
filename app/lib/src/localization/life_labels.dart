import 'package:flutter/material.dart';

import '../features/cats/domain/cat_traits.dart';
import '../features/cats/domain/life_event.dart';
import 'app_localizations.dart';

/// "Passed away 16 Sep 2026", "Born around 2019": the sentence for [event],
/// with its date as precise as it was given, in [locale]. A sterilisation
/// reads "Neutered" for a male and "Spayed" for a female cat ([sex]).
String lifeEventLabel(
  AppLocalizations l10n,
  LifeEvent event,
  String locale, {
  CatSex? sex,
}) {
  final kind = event.on.kind;
  final date = event.on.format(locale);
  return switch (event.type) {
    LifeEventType.born => l10n.lifeBorn(kind, date),
    LifeEventType.missing => l10n.lifeMissing(kind, date),
    LifeEventType.found => l10n.lifeFound(kind, date),
    LifeEventType.sterilised => switch (sex) {
      CatSex.male => l10n.lifeNeutered(kind, date),
      CatSex.female => l10n.lifeSpayed(kind, date),
      null => l10n.lifeSterilised(kind, date),
    },
    LifeEventType.died => l10n.lifeDied(kind, date),
    LifeEventType.health => l10n.lifeHealth(
      kind,
      date,
      healthKindSentence(l10n, event.kind),
    ),
  };
}

/// The choice of a health entry's kind ("Other" for [HealthKind.other]).
String healthKindName(AppLocalizations l10n, HealthKind kind) => switch (kind) {
  HealthKind.vaccination => l10n.healthVaccination,
  HealthKind.dental => l10n.healthDental,
  HealthKind.checkup => l10n.healthCheckup,
  HealthKind.tests => l10n.healthTests,
  HealthKind.surgery => l10n.healthSurgery,
  HealthKind.other => l10n.healthOther,
};

/// The kind as it starts a sentence: "Other" and a missing kind say "Health".
String healthKindSentence(AppLocalizations l10n, HealthKind? kind) =>
    kind == null || kind == HealthKind.other
    ? l10n.healthGeneral
    : healthKindName(l10n, kind);

/// The short name of a type, for the "Add to story" choices and dialogs.
String lifeTypeName(AppLocalizations l10n, LifeEventType type, {CatSex? sex}) =>
    switch (type) {
      LifeEventType.born => l10n.storyAddBorn,
      LifeEventType.missing => l10n.storyAddMissing,
      LifeEventType.found => l10n.storyAddFound,
      LifeEventType.sterilised => switch (sex) {
        CatSex.male => l10n.storyAddNeutered,
        CatSex.female => l10n.storyAddSpayed,
        null => l10n.storyAddSterilised,
      },
      LifeEventType.died => l10n.storyAddDied,
      LifeEventType.health => l10n.storyAddHealth,
    };

IconData lifeTypeIcon(LifeEventType type) => switch (type) {
  LifeEventType.born => Icons.cake_outlined,
  LifeEventType.missing => Icons.search,
  LifeEventType.found => Icons.home_outlined,
  LifeEventType.sterilised => Icons.medical_services_outlined,
  LifeEventType.died => Icons.favorite_border,
  LifeEventType.health => Icons.medical_services_outlined,
};

String catSexName(AppLocalizations l10n, CatSex sex) => switch (sex) {
  CatSex.male => l10n.catSexMale,
  CatSex.female => l10n.catSexFemale,
};

String catHairName(AppLocalizations l10n, CatHair hair) => switch (hair) {
  CatHair.short => l10n.catHairShort,
  CatHair.long => l10n.catHairLong,
};

String catColourName(AppLocalizations l10n, CatColour colour) =>
    switch (colour) {
      CatColour.black => l10n.catColourBlack,
      CatColour.white => l10n.catColourWhite,
      CatColour.grey => l10n.catColourGrey,
      CatColour.orange => l10n.catColourOrange,
      CatColour.tabby => l10n.catColourTabby,
      CatColour.calicoTortie => l10n.catColourCalicoTortie,
      CatColour.mixed => l10n.catColourMixed,
    };

/// "Short hair · tabby": what is set of the coat, or null when neither is.
/// A colour alone starts with a capital.
String? catCoatLine(AppLocalizations l10n, CatHair? hair, CatColour? colour) {
  if (hair == null && colour == null) return null;
  final hairText = hair == null
      ? null
      : (hair == CatHair.short ? l10n.catHairShortLine : l10n.catHairLongLine);
  if (colour == null) return hairText;
  final colourText = catColourName(l10n, colour);
  if (hairText == null) return colourText;
  return '$hairText · ${colourText.toLowerCase()}';
}
