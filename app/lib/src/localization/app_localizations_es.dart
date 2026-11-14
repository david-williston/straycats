// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'StrayCats';

  @override
  String get cantOpenCatsFolder => 'No se pudieron cargar tus gatos.';

  @override
  String get noCatsYet =>
      'Aún no hay gatos. Toca la cámara para conocer a uno.';

  @override
  String get meetACat => 'Conocer a un gato';

  @override
  String get noNameYet => 'Aún sin nombre';

  @override
  String get whoIsThis => '¿Quién es?';

  @override
  String get isItOneOfThese => '¿Es alguno de estos?';

  @override
  String get noCatsYetFirst => 'Aún no hay gatos. Este será el primero.';

  @override
  String get newCat => 'Gato nuevo';

  @override
  String get thisCat => 'Este gato';

  @override
  String get done => 'Listo';

  @override
  String get nameOptional => 'Nombre (opcional)';

  @override
  String get name => 'Nombre';

  @override
  String get giveCatAName => 'Ponle un nombre a este gato';

  @override
  String get language => 'Idioma';

  @override
  String get phoneLanguage => 'Idioma del teléfono';

  @override
  String get startupLoading => 'Preparando tus gatos…';

  @override
  String get firstLaunchNeedsInternet =>
      'Conéctate a internet para configurar la app. Solo hace falta una vez.';

  @override
  String get startupFailed => 'Algo salió mal al iniciar la app.';

  @override
  String get retry => 'Reintentar';

  @override
  String get whatWasItDoing => '¿Qué estaba haciendo?';

  @override
  String get howDidItLook => '¿Cómo se veía?';

  @override
  String get howDidYouHelp => '¿Lo ayudaste?';

  @override
  String get noteLabel => 'Su historia (opcional)';

  @override
  String get noteHint => '¿Qué debería saber la próxima persona?';

  @override
  String get activityEating => 'Comiendo';

  @override
  String get activitySleeping => 'Durmiendo';

  @override
  String get activityResting => 'Descansando';

  @override
  String get activityWaitingAtDoor => 'Esperando en una puerta';

  @override
  String get activityPlaying => 'Jugando';

  @override
  String get activityWalkingBy => 'Caminando';

  @override
  String get conditionHealthy => 'Se ve sano';

  @override
  String get conditionThin => 'Muy delgado';

  @override
  String get conditionLimping => 'Cojeando';

  @override
  String get conditionUnwellOrInjured => 'Enfermo o herido';

  @override
  String get conditionWithKittens => 'Con gatitos';

  @override
  String get conditionEarTipped => 'Oreja cortada';

  @override
  String get careFed => 'Le di de comer';

  @override
  String get careGaveWater => 'Le di agua';

  @override
  String get careTookToVet => 'Lo llevé al veterinario';

  @override
  String get careGaveMedicine => 'Le di medicina';

  @override
  String get editEncounter => 'Editar encuentro';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get deleteEncounterTitle => '¿Eliminar este encuentro?';

  @override
  String get deleteEncounterBody => 'Se quitará del historial de este gato.';

  @override
  String get account => 'Cuenta';

  @override
  String get accountNotSignedIn =>
      'Sin iniciar sesión. Tus gatos solo están en la cuenta de este teléfono.';

  @override
  String get signInWithGoogle => 'Iniciar sesión con Google';

  @override
  String signedInAs(String who) {
    return 'Sesión iniciada como $who';
  }

  @override
  String get googleLinked =>
      'Listo. Tus gatos ahora están guardados en tu cuenta de Google.';

  @override
  String get googleSwitched =>
      'Sesión iniciada. Tus gatos de antes han vuelto.';

  @override
  String get googleSwitchedKeptOld =>
      'Sesión iniciada en tu cuenta de Google. Los gatos de la cuenta anterior de este teléfono no se añadieron a ella.';

  @override
  String get signInFailed =>
      'No se pudo iniciar sesión. Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get signOutTitle => '¿Cerrar sesión?';

  @override
  String get signOutBody =>
      'Tus gatos siguen a salvo en tu cuenta de Google. Inicia sesión con Google de nuevo para recuperarlos.';

  @override
  String signOutPendingBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotos no han terminado de subirse.',
      one: '1 foto no ha terminado de subirse.',
    );
    return '$_temp0 Esperan en este teléfono y se suben la próxima vez que inicies sesión en esta cuenta.';
  }

  @override
  String get signOutWait => 'Esperar';

  @override
  String get signOutAnyway => 'Cerrar sesión igualmente';

  @override
  String get signOutFailed =>
      'No se pudo cerrar la sesión. Inténtalo de nuevo.';

  @override
  String get uploadsDone =>
      'Todas tus fotos están subidas. Ya puedes cerrar la sesión.';

  @override
  String get uploadsStillWaiting => 'Algunas fotos siguen esperando conexión.';

  @override
  String get accountKeepSafeHint =>
      'Inicia sesión con Google para mantener a salvo tus gatos. Así también podrás cerrar sesión, por ejemplo para probar la app como otra persona.';

  @override
  String get nicknameOptional => 'Apodo (opcional)';

  @override
  String get nicknameHint => '¿Cómo te llamamos?';

  @override
  String get nicknameSaved => 'Apodo guardado';

  @override
  String get nicknameNotSaved => 'No se pudo guardar el apodo';

  @override
  String get people => 'Personas';

  @override
  String get noPeopleYet => 'Aún no hay personas.';

  @override
  String get cantLoadPeople => 'No se pudo cargar la lista.';

  @override
  String joinedOn(String date) {
    return 'Se unió el $date';
  }

  @override
  String get viewingSomeoneElse =>
      'Viendo los gatos de otra persona. Solo lectura.';

  @override
  String get personNoCats => 'Esta persona aún no tiene gatos.';

  @override
  String seenAround(String places) {
    return 'Visto por $places';
  }

  @override
  String placeAround(String name) {
    return 'Cerca de $name (aprox. 1 km)';
  }

  @override
  String get placeAroundUnnamed => 'Por esta zona (aprox. 1 km)';

  @override
  String get removePlace => 'Quitar el lugar';

  @override
  String get placePrivacyNote =>
      'Solo se guarda en línea esta zona aproximada. Tu ubicación exacta nunca se guarda.';

  @override
  String get approximateAreaMap => 'Mapa de la zona aproximada';

  @override
  String get shareCard => 'Compartir este gato';

  @override
  String get shareButton => 'Compartir';

  @override
  String get shareFailed =>
      'No se pudo compartir la tarjeta. Inténtalo de nuevo.';

  @override
  String get shareCardNoName => 'Un gato sin nombre todavía';

  @override
  String shareCardKnownSince(String date) {
    return 'Conocido desde el $date';
  }

  @override
  String thisMightBe(String name) {
    return 'Podría ser $name. ¿Es este?';
  }

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get notSure => 'No estoy seguro';

  @override
  String get seenInThisArea => 'Visto antes en esta zona';

  @override
  String get seenNearby => 'Visto cerca de aquí';

  @override
  String get seenRecently => 'Visto hace poco';

  @override
  String lifeBorn(String kind, String date) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'day': 'Nació el $date',
      'month': 'Nació en $date',
      'year': 'Nació en $date',
      'around': 'Nació alrededor de $date',
      'other': 'Nació el $date',
    });
    return '$_temp0';
  }

  @override
  String lifeSterilised(String kind, String date) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'day': 'Esterilización el $date',
      'month': 'Esterilización en $date',
      'year': 'Esterilización en $date',
      'around': 'Esterilización alrededor de $date',
      'other': 'Esterilización el $date',
    });
    return '$_temp0';
  }

  @override
  String lifeDied(String kind, String date) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'day': 'Falleció el $date',
      'month': 'Falleció en $date',
      'year': 'Falleció en $date',
      'around': 'Falleció alrededor de $date',
      'other': 'Falleció el $date',
    });
    return '$_temp0';
  }

  @override
  String lifeMissing(String kind, String date) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'day': 'Se perdió el $date',
      'month': 'Se perdió en $date',
      'year': 'Se perdió en $date',
      'around': 'Se perdió alrededor de $date',
      'other': 'Se perdió el $date',
    });
    return '$_temp0';
  }

  @override
  String lifeFound(String kind, String date) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'day': 'Apareció el $date',
      'month': 'Apareció en $date',
      'year': 'Apareció en $date',
      'around': 'Apareció alrededor de $date',
      'other': 'Apareció el $date',
    });
    return '$_temp0';
  }

  @override
  String get lifeRemembered => 'En su memoria';

  @override
  String lifeRememberedDates(String first, String last) {
    return '$first – $last';
  }

  @override
  String get storyAdd => 'Añadir a su historia';

  @override
  String get storyAddMissing => 'Se perdió';

  @override
  String get storyAddFound => 'Apareció';

  @override
  String get storyAddBorn => 'Nació';

  @override
  String get storyAddSterilised => 'Esterilización';

  @override
  String get storyAddDied => 'Falleció';

  @override
  String storyAlreadyIn(String entry) {
    return 'Ya está en su historia: $entry';
  }

  @override
  String get storyChangeDate => 'Cambiar la fecha';

  @override
  String get storyAddAnother => 'Añadir otra de todos modos';

  @override
  String get storyPrecisionDay => 'Día';

  @override
  String get storyPrecisionMonth => 'Mes';

  @override
  String get storyPrecisionYear => 'Año';

  @override
  String get storyAround => 'Alrededor';

  @override
  String get storyDateYear => 'Año';

  @override
  String get storyDateMonth => 'Mes';

  @override
  String get storyDateDay => 'Día';

  @override
  String get storyNoteLabel => 'Una nota (opcional)';

  @override
  String get storyMissingHelp =>
      'Di cuándo se vio por última vez. Si quieres, añade unas palabras sobre dónde. Por favor, no escribas una dirección.';

  @override
  String get storyMissingNoteHint => 'Por ejemplo, cerca del mercado el martes';

  @override
  String get storyFoundHelp => 'Qué buena noticia. ¿Cuándo apareció?';

  @override
  String get storyBornHelp =>
      '¿Cuándo nació este gato? Basta con el año, o más o menos.';

  @override
  String get storySterilisedHelp =>
      '¿Cuándo se esterilizó este gato, si lo sabes? Basta con el año.';

  @override
  String get storyDiedHelp =>
      'Lo sentimos mucho. El registro sigue abierto y puedes seguir añadiendo cosas. ¿Cuándo falleció este gato?';

  @override
  String get storyNoteHintDied => 'Unas palabras en su memoria';

  @override
  String storyCelebrationNamed(String name) {
    return '¡$name apareció! ¡Bienvenido a casa!';
  }

  @override
  String get storyCelebrationUnnamed =>
      '¡Este gato apareció! ¡Bienvenido a casa!';

  @override
  String get storyCelebrationClose => 'Qué alegría';

  @override
  String get storyYouRecorded => 'Lo registraste tú';

  @override
  String get storyEntryOptions => 'Editar o eliminar esta entrada';

  @override
  String get storyEditTitle => 'Editar esta entrada';

  @override
  String get storyDeleteTitle => '¿Eliminar esta entrada?';

  @override
  String get storyDeleteBody =>
      'Se quitará de su historia. El gato, sus fotos y sus otras entradas se quedan.';

  @override
  String get storyConflictTitle => 'Puede que no coincidan — revísalos';

  @override
  String storyConflictDuplicate(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'born': 'Hay dos fechas de su nacimiento. ¿Alguna está mal?',
      'sterilised': 'Hay dos fechas de su esterilización. ¿Alguna está mal?',
      'other': 'Hay dos fechas de su fallecimiento. ¿Alguna está mal?',
    });
    return '$_temp0';
  }

  @override
  String storyConflictSighting(String date) {
    return 'Hay una foto del $date, posterior a su fallecimiento. ¿Alguna de las dos está mal?';
  }

  @override
  String get storyConflictFoundAfterDeath =>
      'Se registró que apareció después de su fallecimiento. ¿Alguna de las dos está mal?';

  @override
  String storyNudgeFound(String date) {
    return 'Visto el $date. ¿Apareció?';
  }

  @override
  String get storyEarTipOffer =>
      'Oreja cortada: ¿añadir la esterilización a su historia?';

  @override
  String get storyEarTipAdd => 'Añadir';

  @override
  String get storyEarTipNotNow => 'Ahora no';

  @override
  String lifeRangeAround(String date) {
    return 'alrededor de $date';
  }

  @override
  String lifeRememberedConflict(String first) {
    return '$first – hay dos fechas registradas';
  }

  @override
  String get lifeRememberedConflictOnly =>
      'Hay dos fechas registradas de su fallecimiento';

  @override
  String get catLooksTitle => 'Sobre este gato';

  @override
  String get catSexLabel => 'Sexo';

  @override
  String get catSexMale => 'Macho';

  @override
  String get catSexFemale => 'Hembra';

  @override
  String get catNotSure => 'No lo sé';

  @override
  String get catHairLabel => 'Pelo';

  @override
  String get catHairShort => 'Corto';

  @override
  String get catHairLong => 'Largo';

  @override
  String get catColourLabel => 'Color';

  @override
  String get catColourBlack => 'Negro';

  @override
  String get catColourWhite => 'Blanco';

  @override
  String get catColourGrey => 'Gris';

  @override
  String get catColourOrange => 'Naranja';

  @override
  String get catColourTabby => 'Atigrado';

  @override
  String get catColourCalicoTortie => 'Tricolor / carey';

  @override
  String get catColourMixed => 'Mezclado';

  @override
  String get catHairShortLine => 'Pelo corto';

  @override
  String get catHairLongLine => 'Pelo largo';

  @override
  String lifeNeutered(String kind, String date) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'day': 'Castrado el $date',
      'month': 'Castrado en $date',
      'year': 'Castrado en $date',
      'around': 'Castrado alrededor de $date',
      'other': 'Castrado el $date',
    });
    return '$_temp0';
  }

  @override
  String lifeSpayed(String kind, String date) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'day': 'Esterilizada el $date',
      'month': 'Esterilizada en $date',
      'year': 'Esterilizada en $date',
      'around': 'Esterilizada alrededor de $date',
      'other': 'Esterilizada el $date',
    });
    return '$_temp0';
  }

  @override
  String get storyAddNeutered => 'Castrado';

  @override
  String get storyAddSpayed => 'Esterilizada';

  @override
  String get storyAddHealth => 'Salud';

  @override
  String get storyHealthKindLabel => '¿De qué se trató?';

  @override
  String get healthVaccination => 'Vacunación';

  @override
  String get healthDental => 'Dental';

  @override
  String get healthCheckup => 'Revisión';

  @override
  String get healthTests => 'Análisis';

  @override
  String get healthSurgery => 'Cirugía';

  @override
  String get healthOther => 'Otro';

  @override
  String get healthGeneral => 'Salud';

  @override
  String lifeHealth(String kind, String date, String health) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'day': '$health el $date',
      'month': '$health en $date',
      'year': '$health en $date',
      'around': '$health alrededor de $date',
      'other': '$health el $date',
    });
    return '$_temp0';
  }

  @override
  String get storyHealthHelp =>
      '¿Qué se hizo y cuándo? Basta con el año si no estás seguro.';

  @override
  String get storyHealthNoteHint =>
      'Veterinario, medicina, cualquier cosa que valga la pena recordar';
}
