import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../localization/app_localizations.dart';
import '../../cats/domain/cat.dart';
import '../../cats/presentation/cat_card.dart';
import '../../cats/presentation/cat_tile.dart';
import '../data/people_repository.dart';
import '../domain/person.dart';

/// Admin only: one person's cats and encounters, read only. No camera, and the
/// cards cannot rename, edit or delete. Fetched once, not listened to.
class PersonCatsPage extends ConsumerWidget {
  const PersonCatsPage({super.key, required this.person});

  final Person person;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final cats = ref.watch(personCatsProvider(person.uid));
    return Scaffold(
      appBar: AppBar(
        title: Text(
          person.nickname ?? person.uid,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Column(
        children: [
          MaterialBanner(
            content: Text(l10n.viewingSomeoneElse),
            actions: const [SizedBox.shrink()],
          ),
          Expanded(
            child: cats.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Center(child: Text(l10n.cantLoadPeople)),
              data: (list) {
                final sorted = byLastSeen(list);
                return sorted.isEmpty
                    ? Center(child: Text(l10n.personNoCats))
                    : GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              childAspectRatio: 0.85,
                            ),
                        itemCount: sorted.length,
                        itemBuilder: (context, i) => GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  CatCard(cat: sorted[i], ownerUid: person.uid),
                            ),
                          ),
                          child: CatTile(cat: sorted[i], ownerUid: person.uid),
                        ),
                      );
              },
            ),
          ),
        ],
      ),
    );
  }
}
