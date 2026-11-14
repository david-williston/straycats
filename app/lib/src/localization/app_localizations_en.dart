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
  String get welcomeLine => 'Let\'s go meet some cats.';

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
  String get signOut => 'Sign out';

  @override
  String get signOutTitle => 'Sign out?';

  @override
  String get signOutBody =>
      'Your cats stay safe in your Google account. Sign in with Google again to get them back.';

  @override
  String signOutPendingBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos haven\'t finished uploading.',
      one: '1 photo hasn\'t finished uploading.',
    );
    return '$_temp0 They wait on this phone and upload the next time you sign in to this account.';
  }

  @override
  String get signOutWait => 'Wait';

  @override
  String get signOutAnyway => 'Sign out anyway';

  @override
  String get signOutFailed => 'Could not sign out. Try again.';

  @override
  String get uploadsDone =>
      'All your photos are uploaded. You can sign out now.';

  @override
  String get uploadsStillWaiting =>
      'Some photos are still waiting for a connection.';

  @override
  String get accountKeepSafeHint =>
      'Sign in with Google to keep your cats safe. Then you can also sign out, for example to try the app as someone else.';

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

  @override
  String thisMightBe(String name) {
    return 'This might be $name. Is it?';
  }

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get notSure => 'Not sure';

  @override
  String get seenInThisArea => 'Seen in this area before';

  @override
  String get seenNearby => 'Seen nearby';

  @override
  String get seenRecently => 'Seen recently';

  @override
  String lifeBorn(String kind, String date) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'day': 'Born $date',
      'month': 'Born $date',
      'year': 'Born in $date',
      'around': 'Born around $date',
      'other': 'Born $date',
    });
    return '$_temp0';
  }

  @override
  String lifeSterilised(String kind, String date) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'day': 'Sterilised on $date',
      'month': 'Sterilised in $date',
      'year': 'Sterilised in $date',
      'around': 'Sterilised around $date',
      'other': 'Sterilised on $date',
    });
    return '$_temp0';
  }

  @override
  String lifeDied(String kind, String date) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'day': 'Passed away $date',
      'month': 'Passed away in $date',
      'year': 'Passed away in $date',
      'around': 'Passed away around $date',
      'other': 'Passed away $date',
    });
    return '$_temp0';
  }

  @override
  String lifeMissing(String kind, String date) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'day': 'Missing since $date',
      'month': 'Missing since $date',
      'year': 'Missing since $date',
      'around': 'Missing since around $date',
      'other': 'Missing since $date',
    });
    return '$_temp0';
  }

  @override
  String lifeFound(String kind, String date) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'day': 'Found $date',
      'month': 'Found in $date',
      'year': 'Found in $date',
      'around': 'Found around $date',
      'other': 'Found $date',
    });
    return '$_temp0';
  }

  @override
  String get lifeRemembered => 'Remembered';

  @override
  String lifeRememberedDates(String first, String last) {
    return '$first – $last';
  }

  @override
  String get storyAdd => 'Add to story';

  @override
  String get storyAddMissing => 'Went missing';

  @override
  String get storyAddFound => 'Found';

  @override
  String get storyAddBorn => 'Born';

  @override
  String get storyAddSterilised => 'Sterilised';

  @override
  String get storyAddDied => 'Passed away';

  @override
  String storyAlreadyIn(String entry) {
    return 'Already in the story: $entry';
  }

  @override
  String get storyChangeDate => 'Change the date';

  @override
  String get storyAddAnother => 'Add another anyway';

  @override
  String get storyPrecisionDay => 'Day';

  @override
  String get storyPrecisionMonth => 'Month';

  @override
  String get storyPrecisionYear => 'Year';

  @override
  String get storyAround => 'Around';

  @override
  String get storyDateYear => 'Year';

  @override
  String get storyDateMonth => 'Month';

  @override
  String get storyDateDay => 'Day';

  @override
  String get storyNoteLabel => 'A note (optional)';

  @override
  String get storyMissingHelp =>
      'Say when it was last seen. If you like, add a few words about where. Please don\'t write an address.';

  @override
  String get storyMissingNoteHint => 'For example, near the market on Tuesday';

  @override
  String get storyFoundHelp => 'What good news. When was it found?';

  @override
  String get storyBornHelp =>
      'When was this cat born? A year is fine, or around a year.';

  @override
  String get storySterilisedHelp =>
      'When was this cat sterilised, if you know? A year is fine.';

  @override
  String get storyDiedHelp =>
      'We\'re so sorry. The record stays open, and you can keep adding to it. When did this cat pass away?';

  @override
  String get storyNoteHintDied => 'A few words in memory';

  @override
  String storyCelebrationNamed(String name) {
    return '$name is found. Welcome home!';
  }

  @override
  String get storyCelebrationUnnamed => 'This cat is found. Welcome home!';

  @override
  String get storyCelebrationClose => 'Wonderful';

  @override
  String get storyYouRecorded => 'You recorded this';

  @override
  String get storyEntryOptions => 'Edit or delete this entry';

  @override
  String get storyEditTitle => 'Edit this entry';

  @override
  String get storyDeleteTitle => 'Delete this entry?';

  @override
  String get storyDeleteBody =>
      'It will be removed from the story. The cat, its photos and its other entries stay.';

  @override
  String get storyConflictTitle => 'Possible conflict — check these';

  @override
  String storyConflictDuplicate(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'born': 'Two dates for when this cat was born. Is one of them wrong?',
      'sterilised':
          'Two dates for when this cat was sterilised. Is one of them wrong?',
      'other': 'Two dates for when this cat passed away. Is one of them wrong?',
    });
    return '$_temp0';
  }

  @override
  String storyConflictSighting(String date) {
    return 'There\'s a sighting on $date, after this cat was recorded as having passed away. Is one of them wrong?';
  }

  @override
  String get storyConflictFoundAfterDeath =>
      'This cat is recorded as found after it was recorded as having passed away. Is one of them wrong?';

  @override
  String storyNudgeFound(String date) {
    return 'Seen on $date. Found?';
  }

  @override
  String get storyEarTipOffer => 'Ear-tipped: add sterilisation to the story?';

  @override
  String get storyEarTipAdd => 'Add';

  @override
  String get storyEarTipNotNow => 'Not now';

  @override
  String lifeRangeAround(String date) {
    return 'around $date';
  }

  @override
  String lifeRememberedConflict(String first) {
    return '$first – two dates recorded';
  }

  @override
  String get lifeRememberedConflictOnly =>
      'Two dates recorded for when this cat passed away';

  @override
  String get catLooksTitle => 'About this cat';

  @override
  String get catSexLabel => 'Sex';

  @override
  String get catSexMale => 'Male';

  @override
  String get catSexFemale => 'Female';

  @override
  String get catNotSure => 'Not sure';

  @override
  String get catHairLabel => 'Hair';

  @override
  String get catHairShort => 'Short';

  @override
  String get catHairLong => 'Long';

  @override
  String get catColourLabel => 'Colour';

  @override
  String get catColourBlack => 'Black';

  @override
  String get catColourWhite => 'White';

  @override
  String get catColourGrey => 'Grey';

  @override
  String get catColourOrange => 'Orange';

  @override
  String get catColourTabby => 'Tabby';

  @override
  String get catColourCalicoTortie => 'Calico / tortie';

  @override
  String get catColourMixed => 'Mixed';

  @override
  String get catHairShortLine => 'Short hair';

  @override
  String get catHairLongLine => 'Long hair';

  @override
  String lifeNeutered(String kind, String date) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'day': 'Neutered on $date',
      'month': 'Neutered in $date',
      'year': 'Neutered in $date',
      'around': 'Neutered around $date',
      'other': 'Neutered on $date',
    });
    return '$_temp0';
  }

  @override
  String lifeSpayed(String kind, String date) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'day': 'Spayed on $date',
      'month': 'Spayed in $date',
      'year': 'Spayed in $date',
      'around': 'Spayed around $date',
      'other': 'Spayed on $date',
    });
    return '$_temp0';
  }

  @override
  String get storyAddNeutered => 'Neutered';

  @override
  String get storyAddSpayed => 'Spayed';

  @override
  String get storyAddHealth => 'Health';

  @override
  String get storyHealthKindLabel => 'What was it?';

  @override
  String get healthVaccination => 'Vaccination';

  @override
  String get healthDental => 'Dental';

  @override
  String get healthCheckup => 'Check-up';

  @override
  String get healthTests => 'Tests';

  @override
  String get healthSurgery => 'Surgery';

  @override
  String get healthOther => 'Other';

  @override
  String get healthGeneral => 'Health';

  @override
  String lifeHealth(String kind, String date, String health) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'day': '$health on $date',
      'month': '$health in $date',
      'year': '$health in $date',
      'around': '$health around $date',
      'other': '$health on $date',
    });
    return '$_temp0';
  }

  @override
  String get storyHealthHelp =>
      'What was done, and when? A year is fine if you\'re not sure.';

  @override
  String get storyHealthNoteHint => 'Vet, medicine, anything worth remembering';
}
