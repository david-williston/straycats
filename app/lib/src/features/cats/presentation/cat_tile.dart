import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common_widgets/cat_photo.dart';
import '../../../localization/app_localizations.dart';
import '../../admin/data/other_photo_cache.dart';
import '../data/local_photo_cache.dart';
import '../domain/cat.dart';

/// A grid tile: the cat's latest photo with its name (or a quiet hint)
/// beneath. With [ownerUid] the photo is another person's (an admin viewing),
/// read from the separate cache of other people's photos.
class CatTile extends ConsumerWidget {
  const CatTile({super.key, required this.cat, this.ownerUid});

  final Cat cat;
  final String? ownerUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latest = cat.latest;
    final photo = latest == null
        ? null
        : ref
              .watch(
                ownerUid == null
                    ? photoFileProvider(latest.photoId)
                    : ownerPhotoFileProvider(ownerUid!, latest.photoId),
              )
              .value;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final named = cat.name.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: CatPhoto(photo, cacheWidth: 600)),
        const SizedBox(height: 4),
        Text(
          named ? cat.name : l10n.noNameYet,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: named
              ? theme.textTheme.titleSmall
              : theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
        ),
      ],
    );
  }
}
