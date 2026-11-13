import 'package:flutter/material.dart';

import '../../../localization/app_localizations.dart';
import '../../../localization/encounter_labels.dart';
import '../domain/encounter_details.dart';

/// Compact sections for an encounter's optional details: one activity, any
/// conditions, any care, and a note. Everything may stay empty. Calls
/// [onChanged] with the new details after each change.
class EncounterDetailsForm extends StatefulWidget {
  const EncounterDetailsForm({
    super.key,
    this.initial = const EncounterDetails(),
    required this.onChanged,
  });

  final EncounterDetails initial;
  final ValueChanged<EncounterDetails> onChanged;

  @override
  State<EncounterDetailsForm> createState() => _EncounterDetailsFormState();
}

class _EncounterDetailsFormState extends State<EncounterDetailsForm> {
  late final _note = TextEditingController(text: widget.initial.note);
  late Activity? _activity = widget.initial.activity;
  late Set<Condition> _conditions = {...widget.initial.conditions};
  late Set<Care> _care = {...widget.initial.care};

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _changed() => widget.onChanged(
    EncounterDetails(
      activity: _activity,
      // Enum order, so the stored lists are stable.
      conditions: [
        for (final c in Condition.values)
          if (_conditions.contains(c)) c,
      ],
      care: [
        for (final c in Care.values)
          if (_care.contains(c)) c,
      ],
      note: _note.text,
    ),
  );

  Widget _heading(String text) => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 6),
    child: Text(text, style: Theme.of(context).textTheme.titleSmall),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(l10n.whatWasItDoing),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final a in Activity.values)
              ChoiceChip(
                label: Text(a.label(l10n)),
                selected: _activity == a,
                onSelected: (on) {
                  setState(() => _activity = on ? a : null);
                  _changed();
                },
              ),
          ],
        ),
        _heading(l10n.howDidItLook),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final c in Condition.values)
              FilterChip(
                label: Text(c.label(l10n)),
                selected: _conditions.contains(c),
                onSelected: (on) {
                  setState(
                    () => _conditions = {
                      ..._conditions.where((x) => x != c),
                      if (on) c,
                    },
                  );
                  _changed();
                },
              ),
          ],
        ),
        _heading(l10n.howDidYouHelp),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final c in Care.values)
              FilterChip(
                label: Text(c.label(l10n)),
                selected: _care.contains(c),
                onSelected: (on) {
                  setState(
                    () => _care = {..._care.where((x) => x != c), if (on) c},
                  );
                  _changed();
                },
              ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _note,
          maxLength: maxNoteLength,
          maxLines: null,
          minLines: 2,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: l10n.noteLabel,
            hintText: l10n.noteHint,
            border: const OutlineInputBorder(),
          ),
          onChanged: (_) => _changed(),
        ),
      ],
    );
  }
}
