import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common_widgets/cat_photo.dart';
import '../../../theme/app_theme.dart';
import '../../../localization/app_localizations.dart';
import '../../admin/data/other_photo_cache.dart';
import '../data/local_photo_cache.dart';
import '../domain/cat.dart';
import '../domain/life.dart';
import 'life_badge.dart';

/// A grid tile: the cat's latest photo with its name (or a quiet hint)
/// beneath. With [ownerUid] the photo is another person's (an admin viewing),
/// read from the separate cache of other people's photos.
class CatTile extends ConsumerWidget {
  const CatTile({
    super.key,
    required this.cat,
    this.ownerUid,
    this.onTap,
    this.hero = false,
  });

  final Cat cat;
  final String? ownerUid;
  final VoidCallback? onTap;

  /// Whether the photo flies to the cat card's photo when opened.
  final bool hero;

  /// The shared Hero tag of a cat's photo (tile to card).
  static Object heroTag(Cat cat, String? ownerUid) =>
      'cat-photo-${ownerUid ?? ''}-${cat.id}';

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
    final scheme = theme.colorScheme;
    Widget image = CatPhoto(photo, cacheWidth: 600);
    if (hero) image = Hero(tag: heroTag(cat, ownerUid), child: image);
    return Semantics(
      button: onTap != null,
      label: named ? cat.name : l10n.noNameYet,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(catRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(catRadius),
                  border: Border.all(color: scheme.outlineVariant),
                  color: scheme.surfaceContainerHighest,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(catRadius - 1),
                  child: image,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              named ? cat.name : l10n.noNameYet,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: named
                  ? theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    )
                  : theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
            ),
            if (cat.life.state != LifeState.known)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Center(child: LifeBadge(cat: cat, compact: true)),
              ),
            const SizedBox(height: 2),
          ],
        ),
      ),
    );
  }
}
