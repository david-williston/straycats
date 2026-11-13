import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common_widgets/empty_state.dart';
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
          Container(
            width: double.infinity,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  Icons.visibility_outlined,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(l10n.viewingSomeoneElse)),
              ],
            ),
          ),
          Expanded(
            child: cats.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => EmptyState(
                icon: Icons.cloud_off_outlined,
                text: l10n.cantLoadPeople,
              ),
              data: (list) {
                final sorted = byLastSeen(list);
                return sorted.isEmpty
                    ? EmptyState(icon: Icons.pets, text: l10n.personNoCats)
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.8,
                            ),
                        itemCount: sorted.length,
                        itemBuilder: (context, i) => CatTile(
                          cat: sorted[i],
                          ownerUid: person.uid,
                          hero: true,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  CatCard(cat: sorted[i], ownerUid: person.uid),
                            ),
                          ),
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
