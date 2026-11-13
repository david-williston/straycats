import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../localization/app_localizations.dart';
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
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: catsState.hasError
          ? Center(child: Text(l10n.cantOpenCatsFolder))
          : cats == null
          ? const SizedBox.shrink()
          : cats.isEmpty
          ? Center(child: Text(l10n.noCatsYet))
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.85,
              ),
              itemCount: cats.length,
              itemBuilder: (context, i) => GestureDetector(
                onTap: () => _open(context, cats[i]),
                child: CatTile(cat: cats[i]),
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
