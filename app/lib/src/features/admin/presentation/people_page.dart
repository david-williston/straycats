import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../common_widgets/empty_state.dart';
import '../../../localization/app_localizations.dart';
import '../data/other_photo_cache.dart';
import '../data/people_repository.dart';
import 'person_cats_page.dart';

/// Admin only: everyone with a profile, by uid. Read only. The
/// photos of other people that were cached while looking are deleted on the
/// way out.
class PeoplePage extends ConsumerStatefulWidget {
  const PeoplePage({super.key});

  @override
  ConsumerState<PeoplePage> createState() => _PeoplePageState();
}

class _PeoplePageState extends ConsumerState<PeoplePage> {
  late final OtherPhotoCache _cache;

  @override
  void initState() {
    super.initState();
    _cache = ref.read(otherPhotoCacheProvider);
  }

  @override
  void dispose() {
    _cache.clear().catchError((Object _) {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final people = ref.watch(peopleProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.people)),
      body: people.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => EmptyState(
          icon: Icons.cloud_off_outlined,
          text: l10n.cantLoadPeople,
        ),
        data: (list) => list.isEmpty
            ? EmptyState(icon: Icons.groups_outlined, text: l10n.noPeopleYet)
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  for (final person in list)
                    Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: Text(
                          person.uid,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: person.createdAt == null
                            ? null
                            : Text(
                                l10n.joinedOn(
                                  DateFormat.yMMMd(locale)
                                      .format(person.createdAt!),
                                ),
                              ),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => PersonCatsPage(person: person),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
