import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common_widgets/cat_photo.dart';
import '../../../localization/app_localizations.dart';
import '../data/photo_repository.dart';
import '../domain/cat.dart';

/// A grid tile: the cat's latest photo with its name (or a quiet hint)
/// beneath.
class CatTile extends ConsumerWidget {
  const CatTile({super.key, required this.cat});

  final Cat cat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photos = ref.watch(photoRepositoryProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final latest = cat.latest;
    final named = cat.name.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: CatPhoto(
            latest == null ? null : photos.photoFile(latest.photo),
            cacheWidth: 600,
          ),
        ),
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
