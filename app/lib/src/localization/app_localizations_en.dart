// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Stray Cats';

  @override
  String get cantOpenCatsFolder => 'Could not load your cats.';

  @override
  String get noCatsYet => 'No cats yet. Tap the camera to meet one.';

  @override
  String get meetACat => 'Meet a cat';

  @override
  String get noNameYet => 'No name yet';

  @override
  String get whoIsThis => 'Who is this?';

  @override
  String get isItOneOfThese => 'Is it one of these?';

  @override
  String get noCatsYetFirst => 'No cats yet. This one will be the first.';

  @override
  String get newCat => 'New cat';

  @override
  String get thisCat => 'This cat';

  @override
  String get done => 'Done';

  @override
  String get nameOptional => 'Name (optional)';

  @override
  String get whatWasHappening => 'What was happening? (optional)';

  @override
  String get name => 'Name';

  @override
  String get giveCatAName => 'Give this cat a name';

  @override
  String get encounterSeen => 'Just saw it';

  @override
  String get encounterFed => 'Fed it';

  @override
  String get encounterUnwell => 'Looks unwell or injured';

  @override
  String get encounterKittens => 'With kittens';

  @override
  String get encounterEarTipped => 'Ear tipped';

  @override
  String get language => 'Language';

  @override
  String get phoneLanguage => 'Phone\'s language';

  @override
  String get startupLoading => 'Getting your cats ready…';

  @override
  String get firstLaunchNeedsInternet =>
      'Connect to the internet to set up the app. This is needed only once.';

  @override
  String get importNeedsInternet =>
      'Connect to the internet to bring your cats over.';

  @override
  String get importFailed =>
      'Your saved cats could not be read, so nothing was moved. Your photos are untouched.';

  @override
  String get startupFailed => 'Something went wrong starting the app.';

  @override
  String get retry => 'Retry';
}
