import 'dart:io';

import 'package:flutter/material.dart';

import '../../../common_widgets/cat_photo.dart';
import '../../../localization/app_localizations.dart';
import '../domain/cat.dart';
import '../domain/encounter_details.dart';
import '../domain/sighting.dart';
import 'cat_tile.dart';
import 'encounter_details_form.dart';

/// Shown after taking a photo: pick the cat (or "New cat"), then optionally
/// what was happening, then Done. Pops with a [Sighting], or null if the
/// user backs out.
class WhoIsThisPage extends StatefulWidget {
  const WhoIsThisPage({
    super.key,
    required this.photo,
    required this.candidates,
  });

  final File photo;
  final List<Cat> candidates;

  @override
  State<WhoIsThisPage> createState() => _WhoIsThisPageState();
}

class _WhoIsThisPageState extends State<WhoIsThisPage> {
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
          padding: const EdgeInsets.all(16),
          children: [
            SizedBox(
              height: _picked ? 180 : 240,
              child: CatPhoto(widget.photo, cacheWidth: 800),
            ),
            const SizedBox(height: 16),
            ...(_picked ? _details(context) : _choices(context)),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
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

  List<Widget> _choices(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (widget.candidates.isEmpty) {
      return [Text(l10n.noCatsYetFirst)];
    }
    return [
      Text(l10n.isItOneOfThese, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.8,
        ),
        itemCount: widget.candidates.length,
        itemBuilder: (context, i) => GestureDetector(
          onTap: () => _pick(widget.candidates[i]),
          child: CatTile(cat: widget.candidates[i]),
        ),
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
