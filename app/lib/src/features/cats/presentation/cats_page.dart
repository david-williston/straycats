import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common_widgets/empty_state.dart';
import '../../../localization/app_localizations.dart';
import '../../auth/presentation/account_sheet.dart';
import '../../settings/presentation/language_picker.dart';
import '../application/matching_service.dart';
import '../domain/cat.dart';
import '../domain/sighting.dart';
import 'cat_card.dart';
import 'cat_tile.dart';
import 'cats_controller.dart';
import 'meet_cat_controller.dart';
import 'who_is_this_page.dart';

class CatsPage extends ConsumerWidget {
  const CatsPage({super.key});

  /// Takes a photo, asks who it is, and records the encounter. Backing out
  /// of "Who is this?" throws the photo away.
  Future<void> _meet(BuildContext context, WidgetRef ref) async {
    final cats = ref.read(catsControllerProvider).value;
    if (cats == null) return;
    final meet = ref.read(meetCatControllerProvider.notifier);
    final photo = await meet.takePhoto();
    if (photo == null || !context.mounted) return;
    final sighting = await Navigator.of(context).push<Sighting>(
      MaterialPageRoute(
        builder: (_) => WhoIsThisPage(
          photo: photo,
          candidates: ref
              .read(matchingServiceProvider)
              .findMatches(photo, cats),
        ),
      ),
    );
    if (sighting == null) {
      await meet.discard(photo);
      return;
    }
    await ref
        .read(catsControllerProvider.notifier)
        .recordSighting(photo, sighting);
  }

  /// Opens the cat card; its name is saved when the card closes.
  void _open(BuildContext context, Cat cat) {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => CatCard(cat: cat)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final catsState = ref.watch(catsControllerProvider);
    final cats = catsState.value == null ? null : byLastSeen(catsState.value!);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: const [AccountButton(), LanguageButton()],
      ),
      body: catsState.hasError
          ? EmptyState(
              icon: Icons.cloud_off_outlined,
              text: l10n.cantOpenCatsFolder,
            )
          : cats == null
          ? const SizedBox.shrink()
          : cats.isEmpty
          ? EmptyState(icon: Icons.pets, text: l10n.noCatsYet)
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: cats.length,
              itemBuilder: (context, i) => CatTile(
                cat: cats[i],
                hero: true,
                onTap: () => _open(context, cats[i]),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: cats == null ? null : () => _meet(context, ref),
        tooltip: l10n.meetACat,
        child: const Icon(Icons.photo_camera),
      ),
    );
  }
}
