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
  String get whatWasHappening => '¿Qué estaba pasando? (opcional)';

  @override
  String get name => 'Nombre';

  @override
  String get giveCatAName => 'Ponle un nombre a este gato';

  @override
  String get encounterSeen => 'Solo lo vi';

  @override
  String get encounterFed => 'Le di de comer';

  @override
  String get encounterUnwell => 'Parece enfermo o herido';

  @override
  String get encounterKittens => 'Con gatitos';

  @override
  String get encounterEarTipped => 'Oreja cortada';

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
}
