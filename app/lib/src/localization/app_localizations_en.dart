// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'StrayCats';

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
  String get name => 'Name';

  @override
  String get giveCatAName => 'Give this cat a name';

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

  @override
  String get whatWasItDoing => 'What was it doing?';

  @override
  String get howDidItLook => 'How did it look?';

  @override
  String get howDidYouHelp => 'Did you help?';

  @override
  String get noteLabel => 'Its story (optional)';

  @override
  String get noteHint => 'What should the next person know?';

  @override
  String get activityEating => 'Eating';

  @override
  String get activitySleeping => 'Sleeping';

  @override
  String get activityResting => 'Resting';

  @override
  String get activityWaitingAtDoor => 'Waiting at a door';

  @override
  String get activityPlaying => 'Playing';

  @override
  String get activityWalkingBy => 'Walking by';

  @override
  String get conditionHealthy => 'Looks healthy';

  @override
  String get conditionThin => 'Thin';

  @override
  String get conditionLimping => 'Limping';

  @override
  String get conditionUnwellOrInjured => 'Unwell or injured';

  @override
  String get conditionWithKittens => 'With kittens';

  @override
  String get conditionEarTipped => 'Ear tipped';

  @override
  String get careFed => 'Fed it';

  @override
  String get careGaveWater => 'Gave water';

  @override
  String get careTookToVet => 'Took it to the vet';

  @override
  String get careGaveMedicine => 'Gave medicine';

  @override
  String get editEncounter => 'Edit encounter';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get deleteEncounterTitle => 'Delete this encounter?';

  @override
  String get deleteEncounterBody =>
      'It will be removed from this cat\'s history.';

  @override
  String get account => 'Account';

  @override
  String get accountNotSignedIn =>
      'Not signed in. Your cats are only on this phone\'s account.';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String signedInAs(String who) {
    return 'Signed in as $who';
  }

  @override
  String get googleLinked =>
      'Done. Your cats are now kept in your Google account.';

  @override
  String get googleSwitched => 'Signed in. Your cats from before are back.';

  @override
  String get googleSwitchedKeptOld =>
      'Signed in to your Google account. The cats on this phone\'s earlier account were not added to it.';

  @override
  String get signInFailed =>
      'Could not sign in. Check your connection and try again.';

  @override
  String get nicknameOptional => 'Nickname (optional)';

  @override
  String get nicknameHint => 'What should we call you?';

  @override
  String get nicknameSaved => 'Nickname saved';

  @override
  String get nicknameNotSaved => 'Could not save the nickname';

  @override
  String get people => 'People';

  @override
  String get noPeopleYet => 'No people yet.';

  @override
  String get cantLoadPeople => 'Could not load the list.';

  @override
  String joinedOn(String date) {
    return 'Joined $date';
  }

  @override
  String get viewingSomeoneElse => 'Viewing someone else\'s cats. Read only.';

  @override
  String get personNoCats => 'This person has no cats yet.';

  @override
  String seenAround(String places) {
    return 'Seen around $places';
  }

  @override
  String placeAround(String name) {
    return 'Around $name (approx. 1 km)';
  }

  @override
  String get placeAroundUnnamed => 'Around here (approx. 1 km)';

  @override
  String get removePlace => 'Remove place';

  @override
  String get placePrivacyNote =>
      'Only this rough area is stored online. Your exact spot is never saved.';

  @override
  String get approximateAreaMap => 'Map of the approximate area';

  @override
  String get shareCard => 'Share this cat';

  @override
  String get shareButton => 'Share';

  @override
  String get shareFailed => 'The card could not be shared. Please try again.';

  @override
  String get shareCardNoName => 'A cat with no name yet';

  @override
  String shareCardKnownSince(String date) {
    return 'Known since $date';
  }
}
