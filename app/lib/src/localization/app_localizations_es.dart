// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Stray Cats';

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
  String get importNeedsInternet =>
      'Conéctate a internet para traer tus gatos.';

  @override
  String get importFailed =>
      'No se pudieron leer tus gatos guardados, así que no se movió nada. Tus fotos siguen intactas.';

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
}
