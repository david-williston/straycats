import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../localization/app_localizations.dart';
import '../../../localization/life_labels.dart';
import '../domain/cat.dart';
import '../domain/cat_traits.dart';
import 'cats_controller.dart';

/// On the cat card: a quiet line with what is known of the coat ("Short hair
/// · tabby"), or "About this cat" when nothing is. Tapping it opens the
/// choices for sex, hair and colour. Nothing is ever required. Read only (an
/// admin's view) shows the line, only when something is set, and nothing
/// opens.
class CatLooksLine extends ConsumerWidget {
  const CatLooksLine({super.key, required this.cat, this.readOnly = false});

  final Cat cat;
  final bool readOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final coat = catCoatLine(l10n, cat.hair, cat.colour);
    if (readOnly && coat == null) return const SizedBox.shrink();
    final style = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: InkWell(
        onTap: readOnly ? null : () => editCatLooks(context, cat.id),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(child: Text(coat ?? l10n.catLooksTitle, style: style)),
              if (!readOnly)
                Icon(
                  Icons.tune,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A sheet with Sex, Hair and Colour as choice chips, each with "Not sure"
/// selected until something is chosen. A choice is saved at once.
Future<void> editCatLooks(BuildContext context, String catId) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _CatLooksSheet(catId: catId),
    );

class _CatLooksSheet extends ConsumerWidget {
  const _CatLooksSheet({required this.catId});

  final String catId;

  Widget _row<T>(
    BuildContext context,
    String label,
    List<T> values,
    T? current,
    String Function(T) name,
    ValueChanged<T?> onChanged,
  ) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Text(label, style: Theme.of(context).textTheme.labelLarge),
        ),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: Text(l10n.catNotSure),
              selected: current == null,
              onSelected: (_) => onChanged(null),
            ),
            for (final v in values)
              ChoiceChip(
                label: Text(name(v)),
                selected: current == v,
                onSelected: (_) => onChanged(v),
              ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final cat = ref
        .watch(catsControllerProvider)
        .value
        ?.where((c) => c.id == catId)
        .firstOrNull;
    if (cat == null) return const SizedBox.shrink();
    final controller = ref.read(catsControllerProvider.notifier);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _row<CatSex>(
              context,
              l10n.catSexLabel,
              CatSex.values,
              cat.sex,
              (s) => catSexName(l10n, s),
              (v) => controller.setLooks(catId, setSex: true, sex: v),
            ),
            _row<CatHair>(
              context,
              l10n.catHairLabel,
              CatHair.values,
              cat.hair,
              (h) => catHairName(l10n, h),
              (v) => controller.setLooks(catId, setHair: true, hair: v),
            ),
            _row<CatColour>(
              context,
              l10n.catColourLabel,
              CatColour.values,
              cat.colour,
              (c) => catColourName(l10n, c),
              (v) => controller.setLooks(catId, setColour: true, colour: v),
            ),
          ],
        ),
      ),
    );
  }
}
