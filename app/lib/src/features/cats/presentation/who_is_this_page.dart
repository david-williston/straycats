import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common_widgets/cat_photo.dart';
import '../../../localization/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../application/matching_service.dart';
import '../data/local_photo_cache.dart';
import '../domain/cat.dart';
import '../domain/encounter_details.dart';
import '../domain/sighting.dart';
import 'cat_tile.dart';
import 'encounter_details_form.dart';

/// Shown after taking a photo: pick the cat (or "New cat"), then optionally
/// what was happening, then Done. Pops with a [Sighting], or null if the
/// user backs out.
///
/// [matches] are the person's cats, best first. When [suggestion] is given
/// (one cat is clearly ahead) it is offered first as "This might be ...";
/// nothing is ever chosen until the person taps.
class WhoIsThisPage extends ConsumerStatefulWidget {
  const WhoIsThisPage({
    super.key,
    required this.photo,
    required this.matches,
    this.suggestion,
  });

  final File photo;
  final List<CatMatch> matches;
  final CatMatch? suggestion;

  @override
  ConsumerState<WhoIsThisPage> createState() => _WhoIsThisPageState();
}

class _WhoIsThisPageState extends ConsumerState<WhoIsThisPage> {
  /// The cat being suggested, until the person answers No or Not sure.
  late CatMatch? _suggestion = widget.suggestion;
  Cat? _declined;

  final _name = TextEditingController();
  bool _picked = false;
  Cat? _cat;
  EncounterDetails _chosen = const EncounterDetails();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _pick(Cat? cat) => setState(() {
    _picked = true;
    _cat = cat;
  });

  void _done() => Navigator.of(
    context,
  ).pop(Sighting(catId: _cat?.id, name: _name.text.trim(), details: _chosen));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopScope(
      // Back from the second step returns to the first.
      canPop: !_picked,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _picked = false);
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_picked ? _title(l10n) : l10n.whoIsThis)),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: [
            Container(
              height: _picked ? 180 : 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(catRadius * 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.14),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(catRadius * 1.5),
                child: CatPhoto(widget.photo, cacheWidth: 800),
              ),
            ),
            const SizedBox(height: 24),
            ...(_picked ? _details(context) : _choices(context)),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: _picked
                ? FilledButton(onPressed: _done, child: Text(l10n.done))
                : FilledButton.icon(
                    onPressed: () => _pick(null),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.newCat),
                  ),
          ),
        ),
      ),
    );
  }

  String _title(AppLocalizations l10n) {
    final cat = _cat;
    if (cat == null) return l10n.newCat;
    return cat.name.isEmpty ? l10n.thisCat : cat.name;
  }

  List<Cat> get _candidates => [
    for (final m in widget.matches)
      if (m.cat.id != _declined?.id) m.cat,
  ];

  List<Widget> _suggestionCard(BuildContext context, CatMatch match) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final cat = match.cat;
    final latest = cat.latest;
    final file = latest == null
        ? null
        : ref.watch(photoFileProvider(latest.photoId)).value;
    final name = cat.name.isEmpty ? l10n.noNameYet : cat.name;
    Widget photo(File? f) => AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(catRadius),
        child: CatPhoto(f, cacheWidth: 400),
      ),
    );
    return [
      Card(
        key: const Key('suggestion'),
        color: scheme.secondaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: photo(widget.photo)),
                  const SizedBox(width: 12),
                  Expanded(child: photo(file)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                l10n.thisMightBe(name),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                _reason(l10n, match.reason),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(onPressed: () => _pick(cat), child: Text(l10n.yes)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() {
                        _declined = cat;
                        _suggestion = null;
                      }),
                      child: Text(l10n.no),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _suggestion = null),
                      child: Text(l10n.notSure),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ];
  }

  String _reason(AppLocalizations l10n, MatchReason r) => switch (r) {
    MatchReason.sameArea => l10n.seenInThisArea,
    MatchReason.nearbyArea => l10n.seenNearby,
    MatchReason.recentlySeen => l10n.seenRecently,
  };

  List<Widget> _choices(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final suggestion = _suggestion;
    if (suggestion != null) return _suggestionCard(context, suggestion);
    final candidates = _candidates;
    if (candidates.isEmpty) {
      return [
        Text(
          l10n.noCatsYetFirst,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ];
    }
    return [
      Text(l10n.isItOneOfThese, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 12),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 16,
          crossAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemCount: candidates.length,
        itemBuilder: (context, i) =>
            CatTile(cat: candidates[i], onTap: () => _pick(candidates[i])),
      ),
    ];
  }

  List<Widget> _details(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      if (_cat == null) ...[
        TextField(
          controller: _name,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: l10n.nameOptional,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
      ],
      EncounterDetailsForm(onChanged: (d) => _chosen = d),
    ];
  }
}
