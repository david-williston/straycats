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

  /// Shown at start-up when moving the cats saved on this phone to the cloud did not finish for lack of a connection.
  ///
  /// In en, this message translates to:
  /// **'Connect to the internet to bring your cats over.'**
  String get importNeedsInternet;

  /// Shown at start-up when the old cats file on the phone is damaged and the import stops.
  ///
  /// In en, this message translates to:
  /// **'Your saved cats could not be read, so nothing was moved. Your photos are untouched.'**
  String get importFailed;

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
