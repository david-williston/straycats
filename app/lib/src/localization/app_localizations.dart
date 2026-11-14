import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'localization/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// The app name, shown in the title bar of the home screen.
  ///
  /// In en, this message translates to:
  /// **'StrayCats'**
  String get appTitle;

  /// Shown on the home screen when the saved cats cannot be loaded.
  ///
  /// In en, this message translates to:
  /// **'Could not load your cats.'**
  String get cantOpenCatsFolder;

  /// Empty state of the home screen.
  ///
  /// In en, this message translates to:
  /// **'No cats yet. Tap the camera to meet one.'**
  String get noCatsYet;

  /// Tooltip of the camera button that starts meeting a cat.
  ///
  /// In en, this message translates to:
  /// **'Meet a cat'**
  String get meetACat;

  /// Quiet hint under a cat's photo when it has no name.
  ///
  /// In en, this message translates to:
  /// **'No name yet'**
  String get noNameYet;

  /// Title of the screen shown after taking a photo, asking which cat it is.
  ///
  /// In en, this message translates to:
  /// **'Who is this?'**
  String get whoIsThis;

  /// Heading above the existing cats that might match the new photo.
  ///
  /// In en, this message translates to:
  /// **'Is it one of these?'**
  String get isItOneOfThese;

  /// Shown on the Who is this screen when there are no cats to pick from.
  ///
  /// In en, this message translates to:
  /// **'No cats yet. This one will be the first.'**
  String get noCatsYetFirst;

  /// Button and screen title for recording a cat not seen before.
  ///
  /// In en, this message translates to:
  /// **'New cat'**
  String get newCat;

  /// Screen title when the picked cat has no name.
  ///
  /// In en, this message translates to:
  /// **'This cat'**
  String get thisCat;

  /// Button that saves the sighting.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Label of the name field for a new cat.
  ///
  /// In en, this message translates to:
  /// **'Name (optional)'**
  String get nameOptional;

  /// Label of the name field on a cat's card.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Hint text inside the name field on a cat's card.
  ///
  /// In en, this message translates to:
  /// **'Give this cat a name'**
  String get giveCatAName;

  /// Tooltip of the app bar button that opens the language choices, and title of that dialog.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Choice that makes the app follow the language of the phone.
  ///
  /// In en, this message translates to:
  /// **'Phone\'s language'**
  String get phoneLanguage;

  /// Quiet text under the spinner while the app signs in and brings the cats over at start-up.
  ///
  /// In en, this message translates to:
  /// **'Getting your cats ready…'**
  String get startupLoading;

  /// Shown at start-up when the very first launch has no connection and sign-in failed.
  ///
  /// In en, this message translates to:
  /// **'Connect to the internet to set up the app. This is needed only once.'**
  String get firstLaunchNeedsInternet;

  /// Shown at start-up for any other failure, with Retry.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong starting the app.'**
  String get startupFailed;

  /// Button on the start-up message that tries again.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Heading above the activity chips on the encounter form.
  ///
  /// In en, this message translates to:
  /// **'What was it doing?'**
  String get whatWasItDoing;

  /// Heading above the condition chips (healthy, thin, limping...).
  ///
  /// In en, this message translates to:
  /// **'How did it look?'**
  String get howDidItLook;

  /// Heading above the care chips (fed, gave water...).
  ///
  /// In en, this message translates to:
  /// **'Did you help?'**
  String get howDidYouHelp;

  /// Label of the free-text note field on an encounter.
  ///
  /// In en, this message translates to:
  /// **'Its story (optional)'**
  String get noteLabel;

  /// Hint inside the note field.
  ///
  /// In en, this message translates to:
  /// **'What should the next person know?'**
  String get noteHint;

  /// Activity: the cat was eating.
  ///
  /// In en, this message translates to:
  /// **'Eating'**
  String get activityEating;

  /// Activity: the cat was asleep.
  ///
  /// In en, this message translates to:
  /// **'Sleeping'**
  String get activitySleeping;

  /// Activity: the cat was resting, awake.
  ///
  /// In en, this message translates to:
  /// **'Resting'**
  String get activityResting;

  /// Activity: the cat was waiting at a door.
  ///
  /// In en, this message translates to:
  /// **'Waiting at a door'**
  String get activityWaitingAtDoor;

  /// Activity: the cat was playing.
  ///
  /// In en, this message translates to:
  /// **'Playing'**
  String get activityPlaying;

  /// Activity: the cat was just passing by.
  ///
  /// In en, this message translates to:
  /// **'Walking by'**
  String get activityWalkingBy;

  /// Condition: the cat looked healthy.
  ///
  /// In en, this message translates to:
  /// **'Looks healthy'**
  String get conditionHealthy;

  /// Condition: the cat looked thin.
  ///
  /// In en, this message translates to:
  /// **'Thin'**
  String get conditionThin;

  /// Condition: the cat was limping.
  ///
  /// In en, this message translates to:
  /// **'Limping'**
  String get conditionLimping;

  /// Condition: the cat looked sick or hurt.
  ///
  /// In en, this message translates to:
  /// **'Unwell or injured'**
  String get conditionUnwellOrInjured;

  /// Condition: the cat had kittens with it.
  ///
  /// In en, this message translates to:
  /// **'With kittens'**
  String get conditionWithKittens;

  /// Condition: the cat has a tipped ear, the sign it was neutered.
  ///
  /// In en, this message translates to:
  /// **'Ear tipped'**
  String get conditionEarTipped;

  /// Care: the person fed the cat.
  ///
  /// In en, this message translates to:
  /// **'Fed it'**
  String get careFed;

  /// Care: the person gave the cat water.
  ///
  /// In en, this message translates to:
  /// **'Gave water'**
  String get careGaveWater;

  /// Care: the person took the cat to the vet.
  ///
  /// In en, this message translates to:
  /// **'Took it to the vet'**
  String get careTookToVet;

  /// Care: the person gave the cat medicine.
  ///
  /// In en, this message translates to:
  /// **'Gave medicine'**
  String get careGaveMedicine;

  /// Title of the sheet for editing one encounter on a cat's card.
  ///
  /// In en, this message translates to:
  /// **'Edit encounter'**
  String get editEncounter;

  /// Button that saves the edited encounter.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Button that deletes an encounter.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Button that closes a dialog without doing anything.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Title of the confirm dialog before deleting an encounter.
  ///
  /// In en, this message translates to:
  /// **'Delete this encounter?'**
  String get deleteEncounterTitle;

  /// Body of the confirm dialog before deleting an encounter.
  ///
  /// In en, this message translates to:
  /// **'It will be removed from this cat\'s history.'**
  String get deleteEncounterBody;

  /// Tooltip of the account button in the home screen's title bar, and title of the account sheet.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// Shown in the account sheet when the person has not signed in with Google.
  ///
  /// In en, this message translates to:
  /// **'Not signed in. Your cats are only on this phone\'s account.'**
  String get accountNotSignedIn;

  /// Button in the account sheet that signs in with a Google account to keep the cats safe.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// Shown in the account sheet when signed in with Google. who is the person's name or email.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {who}'**
  String signedInAs(String who);

  /// Message after signing in with Google kept the cats of this phone.
  ///
  /// In en, this message translates to:
  /// **'Done. Your cats are now kept in your Google account.'**
  String get googleLinked;

  /// Message after signing in with a Google account that already had cats, and this phone had none.
  ///
  /// In en, this message translates to:
  /// **'Signed in. Your cats from before are back.'**
  String get googleSwitched;

  /// Message after signing in with a Google account that already had cats, while this phone also had cats of its own.
  ///
  /// In en, this message translates to:
  /// **'Signed in to your Google account. The cats on this phone\'s earlier account were not added to it.'**
  String get googleSwitchedKeptOld;

  /// Message when signing in with Google fails.
  ///
  /// In en, this message translates to:
  /// **'Could not sign in. Check your connection and try again.'**
  String get signInFailed;

  /// Button in the account sheet that signs out of the Google account, and the confirm button of its dialog.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// Title of the confirm dialog before signing out of the Google account.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get signOutTitle;

  /// Body of the sign-out confirm dialog when every photo has been uploaded.
  ///
  /// In en, this message translates to:
  /// **'Your cats stay safe in your Google account. Sign in with Google again to get them back.'**
  String get signOutBody;

  /// Body of the sign-out confirm dialog when some photos have not been uploaded yet.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 photo hasn\'t finished uploading.} other{{count} photos haven\'t finished uploading.}} They wait on this phone and upload the next time you sign in to this account.'**
  String signOutPendingBody(int count);

  /// Button in the sign-out dialog that does not sign out and instead tries to upload the waiting photos.
  ///
  /// In en, this message translates to:
  /// **'Wait'**
  String get signOutWait;

  /// Button in the sign-out dialog that signs out although some photos have not uploaded yet.
  ///
  /// In en, this message translates to:
  /// **'Sign out anyway'**
  String get signOutAnyway;

  /// Message when signing out fails.
  ///
  /// In en, this message translates to:
  /// **'Could not sign out. Try again.'**
  String get signOutFailed;

  /// Message after waiting for photos to upload, when none are left.
  ///
  /// In en, this message translates to:
  /// **'All your photos are uploaded. You can sign out now.'**
  String get uploadsDone;

  /// Message after waiting for photos to upload, when some could not be uploaded.
  ///
  /// In en, this message translates to:
  /// **'Some photos are still waiting for a connection.'**
  String get uploadsStillWaiting;

  /// Shown in the account sheet when not signed in with Google, where there is no sign out because the cats would be left behind.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google to keep your cats safe. Then you can also sign out, for example to try the app as someone else.'**
  String get accountKeepSafeHint;

  /// Label of the nickname field in the account sheet.
  ///
  /// In en, this message translates to:
  /// **'Nickname (optional)'**
  String get nicknameOptional;

  /// Hint inside the nickname field.
  ///
  /// In en, this message translates to:
  /// **'What should we call you?'**
  String get nicknameHint;

  /// Message after the nickname was saved.
  ///
  /// In en, this message translates to:
  /// **'Nickname saved'**
  String get nicknameSaved;

  /// Message when saving the nickname fails.
  ///
  /// In en, this message translates to:
  /// **'Could not save the nickname'**
  String get nicknameNotSaved;

  /// Admin only: entry in the account sheet and title of the list of people.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get people;

  /// Admin only: empty state of the list of people.
  ///
  /// In en, this message translates to:
  /// **'No people yet.'**
  String get noPeopleYet;

  /// Admin only: shown when the list of people or someone's cats cannot be loaded.
  ///
  /// In en, this message translates to:
  /// **'Could not load the list.'**
  String get cantLoadPeople;

  /// Admin only: under a person in the list, when their profile was created.
  ///
  /// In en, this message translates to:
  /// **'Joined {date}'**
  String joinedOn(String date);

  /// Admin only: banner above another person's cats.
  ///
  /// In en, this message translates to:
  /// **'Viewing someone else\'s cats. Read only.'**
  String get viewingSomeoneElse;

  /// Admin only: empty state when another person has no cats.
  ///
  /// In en, this message translates to:
  /// **'This person has no cats yet.'**
  String get personNoCats;

  /// Header on a cat's card listing the neighbourhoods where it was met. places is a comma-separated list.
  ///
  /// In en, this message translates to:
  /// **'Seen around {places}'**
  String seenAround(String places);

  /// Label of an encounter's place: a neighbourhood name and a note that it is only approximate.
  ///
  /// In en, this message translates to:
  /// **'Around {name} (approx. 1 km)'**
  String placeAround(String name);

  /// Label of an encounter's place when only the rough area is known, not a neighbourhood name.
  ///
  /// In en, this message translates to:
  /// **'Around here (approx. 1 km)'**
  String get placeAroundUnnamed;

  /// Button in the edit sheet that clears the saved place of an encounter.
  ///
  /// In en, this message translates to:
  /// **'Remove place'**
  String get removePlace;

  /// Small note under an encounter's place in the edit sheet.
  ///
  /// In en, this message translates to:
  /// **'Only this rough area is stored online. Your exact spot is never saved.'**
  String get placePrivacyNote;

  /// Screen reader label for the small map that shows an encounter's approximate area as a circle.
  ///
  /// In en, this message translates to:
  /// **'Map of the approximate area'**
  String get approximateAreaMap;

  /// Tooltip of the app bar button on a cat's card that opens the share card preview, and title of that screen.
  ///
  /// In en, this message translates to:
  /// **'Share this cat'**
  String get shareCard;

  /// Button under the preview of the share card that opens the phone's share sheet.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareButton;

  /// Message shown when making or sharing the card image fails.
  ///
  /// In en, this message translates to:
  /// **'The card could not be shared. Please try again.'**
  String get shareFailed;

  /// On the shareable cat card image: shown in place of the name when the person has not named the cat.
  ///
  /// In en, this message translates to:
  /// **'A cat with no name yet'**
  String get shareCardNoName;

  /// On the shareable cat card image: the date of the first time the cat was met. date is already formatted.
  ///
  /// In en, this message translates to:
  /// **'Known since {date}'**
  String shareCardKnownSince(String date);

  /// Question on the Who is this screen suggesting one of the person's cats for the new photo.
  ///
  /// In en, this message translates to:
  /// **'This might be {name}. Is it?'**
  String thisMightBe(String name);

  /// Button answering yes to the suggested cat.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// Button answering no to the suggested cat; shows the other cats.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// Button for when the person cannot tell if it is the suggested cat; shows all the cats.
  ///
  /// In en, this message translates to:
  /// **'Not sure'**
  String get notSure;

  /// Reason for suggesting a cat that was met in the same neighbourhood as the new photo.
  ///
  /// In en, this message translates to:
  /// **'Seen in this area before'**
  String get seenInThisArea;

  /// Reason for suggesting a cat that was met in a neighbouring area.
  ///
  /// In en, this message translates to:
  /// **'Seen nearby'**
  String get seenNearby;

  /// Reason for suggesting a cat that was met recently.
  ///
  /// In en, this message translates to:
  /// **'Seen recently'**
  String get seenRecently;

  /// An entry in a cat's story: when it was born. kind is day, month, year or around (a rough year); date is already formatted to that precision.
  ///
  /// In en, this message translates to:
  /// **'{kind, select, day{Born {date}} month{Born {date}} year{Born in {date}} around{Born around {date}} other{Born {date}}}'**
  String lifeBorn(String kind, String date);

  /// An entry in a cat's story: when it was sterilised (neutered or spayed). kind is day, month, year or around; date is already formatted.
  ///
  /// In en, this message translates to:
  /// **'{kind, select, day{Sterilised on {date}} month{Sterilised in {date}} year{Sterilised in {date}} around{Sterilised around {date}} other{Sterilised on {date}}}'**
  String lifeSterilised(String kind, String date);

  /// An entry in a cat's story: when it passed away. Gentle and respectful. kind is day, month, year or around; date is already formatted.
  ///
  /// In en, this message translates to:
  /// **'{kind, select, day{Passed away {date}} month{Passed away in {date}} year{Passed away in {date}} around{Passed away around {date}} other{Passed away {date}}}'**
  String lifeDied(String kind, String date);

  /// Badge and story entry on a cat that has gone missing. kind is day, month, year or around; date is already formatted.
  ///
  /// In en, this message translates to:
  /// **'{kind, select, day{Missing since {date}} month{Missing since {date}} year{Missing since {date}} around{Missing since around {date}} other{Missing since {date}}}'**
  String lifeMissing(String kind, String date);

  /// Badge and story entry on a cat that was missing and has been found. kind is day, month, year or around; date is already formatted.
  ///
  /// In en, this message translates to:
  /// **'{kind, select, day{Found {date}} month{Found in {date}} year{Found in {date}} around{Found around {date}} other{Found {date}}}'**
  String lifeFound(String kind, String date);

  /// Quiet badge on a grid tile of a cat that has passed away. Gentle, respectful.
  ///
  /// In en, this message translates to:
  /// **'Remembered'**
  String get lifeRemembered;

  /// The span of a remembered cat's life as we knew it: the date it was first met, then the date it passed away. Both already formatted.
  ///
  /// In en, this message translates to:
  /// **'{first} – {last}'**
  String lifeRememberedDates(String first, String last);

  /// Button on a cat's card that opens the choices for adding something to the cat's story.
  ///
  /// In en, this message translates to:
  /// **'Add to story'**
  String get storyAdd;

  /// Choice and dialog title: say that the cat has gone missing.
  ///
  /// In en, this message translates to:
  /// **'Went missing'**
  String get storyAddMissing;

  /// Choice and dialog title: the cat has been found.
  ///
  /// In en, this message translates to:
  /// **'Found'**
  String get storyAddFound;

  /// Choice and dialog title: when the cat was born.
  ///
  /// In en, this message translates to:
  /// **'Born'**
  String get storyAddBorn;

  /// Choice and dialog title: the cat was sterilised (neutered or spayed). The Spanish is a noun so it has no gender.
  ///
  /// In en, this message translates to:
  /// **'Sterilised'**
  String get storyAddSterilised;

  /// Choice and dialog title: the cat has passed away. Gentle.
  ///
  /// In en, this message translates to:
  /// **'Passed away'**
  String get storyAddDied;

  /// Under a choice that happens once in a cat's life, when the story already has it. entry is the entry's sentence, already formatted.
  ///
  /// In en, this message translates to:
  /// **'Already in the story: {entry}'**
  String storyAlreadyIn(String entry);

  /// Dialog title when changing the date of an entry already in the story.
  ///
  /// In en, this message translates to:
  /// **'Change the date'**
  String get storyChangeDate;

  /// Small link in the change-the-date dialog: add a second entry instead of changing the first.
  ///
  /// In en, this message translates to:
  /// **'Add another anyway'**
  String get storyAddAnother;

  /// Segment: the date is known to the day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get storyPrecisionDay;

  /// Segment: the date is known to the month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get storyPrecisionMonth;

  /// Segment: the date is known to the year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get storyPrecisionYear;

  /// Chip: the year is approximate (around 2019).
  ///
  /// In en, this message translates to:
  /// **'Around'**
  String get storyAround;

  /// Label of the year picker in the story date dialog.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get storyDateYear;

  /// Label of the month picker in the story date dialog.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get storyDateMonth;

  /// Label of the day picker in the story date dialog.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get storyDateDay;

  /// Label of the optional note when adding an entry to a cat's story.
  ///
  /// In en, this message translates to:
  /// **'A note (optional)'**
  String get storyNoteLabel;

  /// Help text in the dialog for saying a cat went missing.
  ///
  /// In en, this message translates to:
  /// **'Say when it was last seen. If you like, add a few words about where. Please don\'t write an address.'**
  String get storyMissingHelp;

  /// Hint in the optional note when a cat went missing. It must not ask for an exact place.
  ///
  /// In en, this message translates to:
  /// **'For example, near the market on Tuesday'**
  String get storyMissingNoteHint;

  /// Help text in the dialog for saying a missing cat was found.
  ///
  /// In en, this message translates to:
  /// **'What good news. When was it found?'**
  String get storyFoundHelp;

  /// Help text in the dialog for the date a cat was born.
  ///
  /// In en, this message translates to:
  /// **'When was this cat born? A year is fine, or around a year.'**
  String get storyBornHelp;

  /// Help text in the dialog for the date a cat was sterilised.
  ///
  /// In en, this message translates to:
  /// **'When was this cat sterilised, if you know? A year is fine.'**
  String get storySterilisedHelp;

  /// Help text in the dialog for a cat that passed away. Gentle and respectful.
  ///
  /// In en, this message translates to:
  /// **'We\'re so sorry. The record stays open, and you can keep adding to it. When did this cat pass away?'**
  String get storyDiedHelp;

  /// Hint in the optional note when a cat passed away.
  ///
  /// In en, this message translates to:
  /// **'A few words in memory'**
  String get storyNoteHintDied;

  /// Message of the small celebration after a named missing cat is found.
  ///
  /// In en, this message translates to:
  /// **'{name} is found. Welcome home!'**
  String storyCelebrationNamed(String name);

  /// Message of the small celebration after a cat with no name is found.
  ///
  /// In en, this message translates to:
  /// **'This cat is found. Welcome home!'**
  String get storyCelebrationUnnamed;

  /// Button that closes the celebration after a cat is found.
  ///
  /// In en, this message translates to:
  /// **'Wonderful'**
  String get storyCelebrationClose;

  /// Under an entry in a cat's story: you wrote it.
  ///
  /// In en, this message translates to:
  /// **'You recorded this'**
  String get storyYouRecorded;

  /// Accessibility label of a story entry that can be tapped to edit or delete it.
  ///
  /// In en, this message translates to:
  /// **'Edit or delete this entry'**
  String get storyEntryOptions;

  /// Title of the sheet for editing an entry in a cat's story.
  ///
  /// In en, this message translates to:
  /// **'Edit this entry'**
  String get storyEditTitle;

  /// Title of the confirmation before deleting an entry of a cat's story.
  ///
  /// In en, this message translates to:
  /// **'Delete this entry?'**
  String get storyDeleteTitle;

  /// Body of the confirmation before deleting an entry of a cat's story.
  ///
  /// In en, this message translates to:
  /// **'It will be removed from the story. The cat, its photos and its other entries stay.'**
  String get storyDeleteBody;

  /// Quiet heading above entries in a cat's story that may disagree.
  ///
  /// In en, this message translates to:
  /// **'Possible conflict — check these'**
  String get storyConflictTitle;

  /// Gentle question when a once-only entry has two different dates. type is born, sterilised or died.
  ///
  /// In en, this message translates to:
  /// **'{type, select, born{Two dates for when this cat was born. Is one of them wrong?} sterilised{Two dates for when this cat was sterilised. Is one of them wrong?} other{Two dates for when this cat passed away. Is one of them wrong?}}'**
  String storyConflictDuplicate(String type);

  /// Gentle question when a photo is dated after a recorded death. date is already formatted.
  ///
  /// In en, this message translates to:
  /// **'There\'s a sighting on {date}, after this cat was recorded as having passed away. Is one of them wrong?'**
  String storyConflictSighting(String date);

  /// Gentle question when a found entry is dated after a recorded death.
  ///
  /// In en, this message translates to:
  /// **'This cat is recorded as found after it was recorded as having passed away. Is one of them wrong?'**
  String get storyConflictFoundAfterDeath;

  /// Tappable nudge on a missing cat that was photographed later: tap to record it as found on that date. date is already formatted.
  ///
  /// In en, this message translates to:
  /// **'Seen on {date}. Found?'**
  String storyNudgeFound(String date);

  /// Offer on a cat card when an encounter says the ear is tipped and the story has no sterilisation. Nothing is added unless the person agrees.
  ///
  /// In en, this message translates to:
  /// **'Ear-tipped: add sterilisation to the story?'**
  String get storyEarTipOffer;

  /// Button accepting the ear-tip offer; opens the sterilisation dialog.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get storyEarTipAdd;

  /// Button declining the ear-tip offer. It is not offered again for this cat.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get storyEarTipNotNow;

  /// Start of a remembered cat's life range when its birth is only a rough year: 'around 2019 – Nov 13, 2026'. date is already formatted.
  ///
  /// In en, this message translates to:
  /// **'around {date}'**
  String lifeRangeAround(String date);

  /// Life range of a remembered cat when the story has two different dates for its passing. first is the already formatted start.
  ///
  /// In en, this message translates to:
  /// **'{first} – two dates recorded'**
  String lifeRememberedConflict(String first);

  /// Life line of a remembered cat with no known start and two different dates for its passing.
  ///
  /// In en, this message translates to:
  /// **'Two dates recorded for when this cat passed away'**
  String get lifeRememberedConflictOnly;

  /// Quiet line on a cat's card, shown when nothing is set, that opens sex and coat choices. Nothing is required.
  ///
  /// In en, this message translates to:
  /// **'About this cat'**
  String get catLooksTitle;

  /// Label of the optional sex choice on a cat's card.
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get catSexLabel;

  /// Choice for a male cat.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get catSexMale;

  /// Choice for a female cat.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get catSexFemale;

  /// Choice meaning the person does not know (sex, hair or colour). Selected by default.
  ///
  /// In en, this message translates to:
  /// **'Not sure'**
  String get catNotSure;

  /// Label of the optional hair length choice.
  ///
  /// In en, this message translates to:
  /// **'Hair'**
  String get catHairLabel;

  /// Choice: short hair.
  ///
  /// In en, this message translates to:
  /// **'Short'**
  String get catHairShort;

  /// Choice: long hair.
  ///
  /// In en, this message translates to:
  /// **'Long'**
  String get catHairLong;

  /// Label of the optional coat colour choice.
  ///
  /// In en, this message translates to:
  /// **'Colour'**
  String get catColourLabel;

  /// Coat colour choice.
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get catColourBlack;

  /// Coat colour choice.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get catColourWhite;

  /// Coat colour choice.
  ///
  /// In en, this message translates to:
  /// **'Grey'**
  String get catColourGrey;

  /// Coat colour choice (ginger cats).
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get catColourOrange;

  /// Coat colour choice: striped or spotted pattern.
  ///
  /// In en, this message translates to:
  /// **'Tabby'**
  String get catColourTabby;

  /// Coat colour choice: calico or tortoiseshell.
  ///
  /// In en, this message translates to:
  /// **'Calico / tortie'**
  String get catColourCalicoTortie;

  /// Coat colour choice: several colours that fit none of the others.
  ///
  /// In en, this message translates to:
  /// **'Mixed'**
  String get catColourMixed;

  /// Compact line on a cat's card: short hair. Followed by the colour, e.g. 'Short hair · tabby'.
  ///
  /// In en, this message translates to:
  /// **'Short hair'**
  String get catHairShortLine;

  /// Compact line on a cat's card: long hair. Followed by the colour, e.g. 'Long hair · black'.
  ///
  /// In en, this message translates to:
  /// **'Long hair'**
  String get catHairLongLine;

  /// An entry in a male cat's story: when it was neutered. kind is day, month, year or around; date is already formatted.
  ///
  /// In en, this message translates to:
  /// **'{kind, select, day{Neutered on {date}} month{Neutered in {date}} year{Neutered in {date}} around{Neutered around {date}} other{Neutered on {date}}}'**
  String lifeNeutered(String kind, String date);

  /// An entry in a female cat's story: when it was spayed. kind is day, month, year or around; date is already formatted.
  ///
  /// In en, this message translates to:
  /// **'{kind, select, day{Spayed on {date}} month{Spayed in {date}} year{Spayed in {date}} around{Spayed around {date}} other{Spayed on {date}}}'**
  String lifeSpayed(String kind, String date);

  /// Choice and dialog title for a male cat: it was neutered.
  ///
  /// In en, this message translates to:
  /// **'Neutered'**
  String get storyAddNeutered;

  /// Choice and dialog title for a female cat: it was spayed.
  ///
  /// In en, this message translates to:
  /// **'Spayed'**
  String get storyAddSpayed;

  /// Choice and dialog title: a health entry in the cat's story (vaccination, vet visit, surgery...).
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get storyAddHealth;

  /// Label above the choices of what a health entry is about.
  ///
  /// In en, this message translates to:
  /// **'What was it?'**
  String get storyHealthKindLabel;

  /// Health entry kind.
  ///
  /// In en, this message translates to:
  /// **'Vaccination'**
  String get healthVaccination;

  /// Health entry kind: teeth and mouth.
  ///
  /// In en, this message translates to:
  /// **'Dental'**
  String get healthDental;

  /// Health entry kind: a vet check-up.
  ///
  /// In en, this message translates to:
  /// **'Check-up'**
  String get healthCheckup;

  /// Health entry kind: lab or other tests.
  ///
  /// In en, this message translates to:
  /// **'Tests'**
  String get healthTests;

  /// Health entry kind: an operation.
  ///
  /// In en, this message translates to:
  /// **'Surgery'**
  String get healthSurgery;

  /// Health entry kind: something else; choice chip.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get healthOther;

  /// Name of a health entry whose kind is 'other' or unknown, used in its sentence.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get healthGeneral;

  /// An entry in a cat's story about its health. health is the kind (Vaccination, Surgery...); kind is day, month, year or around; date is already formatted.
  ///
  /// In en, this message translates to:
  /// **'{kind, select, day{{health} on {date}} month{{health} in {date}} year{{health} in {date}} around{{health} around {date}} other{{health} on {date}}}'**
  String lifeHealth(String kind, String date, String health);

  /// Help text in the dialog for a health entry.
  ///
  /// In en, this message translates to:
  /// **'What was done, and when? A year is fine if you\'re not sure.'**
  String get storyHealthHelp;

  /// Hint in the optional note of a health entry.
  ///
  /// In en, this message translates to:
  /// **'Vet, medicine, anything worth remembering'**
  String get storyHealthNoteHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
