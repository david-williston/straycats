import 'dart:io';

import 'package:flutter/material.dart';

import '../cat.dart';
import '../l10n/app_localizations.dart';
import 'cat_photo.dart';

/// A grid tile: the cat's latest photo with its name (or a quiet hint)
/// beneath.
class CatTile extends StatelessWidget {
  const CatTile({super.key, required this.cat, required this.photoFile});

  final Cat cat;
  final File Function(String name) photoFile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final latest = cat.latest;
    final named = cat.name.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: CatPhoto(
            latest == null ? null : photoFile(latest.photo),
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
