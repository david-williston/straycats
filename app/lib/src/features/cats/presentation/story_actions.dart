import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../localization/app_localizations.dart';
import '../../../localization/life_labels.dart';
import '../domain/cat.dart';
import '../domain/cat_traits.dart';
import '../domain/life_event.dart';
import '../domain/partial_date.dart';
import 'cats_controller.dart';

/// What the person chose in the date dialog: [on] and [note], the [kind] of
/// a health entry, and the entry it [replaces] (null when a new entry is
/// being added).
class LifeEventInput {
  const LifeEventInput(this.on, this.note, this.replaces, {this.kind});

  final PartialDate on;
  final String note;
  final LifeEvent? replaces;
  final HealthKind? kind;
}

const _typesInOrder = [
  LifeEventType.missing,
  LifeEventType.found,
  LifeEventType.born,
  LifeEventType.sterilised,
  LifeEventType.died,
  LifeEventType.health,
];

/// "Add to story": the six choices, then the date dialog. A once-only type
/// that is already in the story says so, and its dialog opens on changing
/// that entry's date, with "Add another anyway" to add a second. Nothing is
/// ever refused.
Future<void> addToStory(
  BuildContext context,
  WidgetRef ref,
  Cat cat, {
  LifeEventType? type,
}) async {
  final l10n = AppLocalizations.of(context);
  final locale = Localizations.localeOf(context).toString();
  final chosen =
      type ??
      await showModalBottomSheet<LifeEventType>(
        context: context,
        showDragHandle: true,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final t in _typesInOrder)
                Builder(
                  builder: (context) {
                    final existing = t.onceOnly ? cat.life.latestOf(t) : null;
                    return ListTile(
                      leading: Icon(lifeTypeIcon(t)),
                      title: Text(lifeTypeName(l10n, t, sex: cat.sex)),
                      subtitle: existing == null
                          ? null
                          : Text(
                              l10n.storyAlreadyIn(
                                lifeEventLabel(
                                  l10n,
                                  existing,
                                  locale,
                                  sex: cat.sex,
                                ),
                              ),
                            ),
                      onTap: () => Navigator.of(context).pop(t),
                    );
                  },
                ),
            ],
          ),
        ),
      );
  if (chosen == null || !context.mounted) return;
  final existing = chosen.onceOnly ? cat.life.latestOf(chosen) : null;
  final input = await showDialog<LifeEventInput>(
    context: context,
    builder: (context) => LifeEventDialog(
      type: chosen,
      sex: cat.sex,
      existing: existing,
      offerAnother: existing != null,
    ),
  );
  if (input == null) return;
  final controller = ref.read(catsControllerProvider.notifier);
  final replaces = input.replaces;
  if (replaces != null) {
    controller.updateEvent(cat.id, replaces, input.on, note: input.note);
    return;
  }
  controller.addEvent(
    cat.id,
    chosen,
    input.on,
    note: input.note,
    kind: input.kind,
  );
  if (chosen == LifeEventType.found && context.mounted) {
    await showDialog<void>(
      context: context,
      builder: (context) => FoundCelebration(name: cat.name),
    );
  }
}

/// Tapping an entry of the story: Edit or Delete (delete asks once).
Future<void> editStoryEntry(
  BuildContext context,
  WidgetRef ref,
  Cat cat,
  LifeEvent event,
) async {
  final l10n = AppLocalizations.of(context);
  final action = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: Text(l10n.storyEditTitle),
            onTap: () => Navigator.of(context).pop(true),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: Text(l10n.delete),
            onTap: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    ),
  );
  if (action == null || !context.mounted) return;
  final controller = ref.read(catsControllerProvider.notifier);
  if (action) {
    final input = await showDialog<LifeEventInput>(
      context: context,
      builder: (context) =>
          LifeEventDialog(type: event.type, sex: cat.sex, existing: event),
    );
    if (input == null) return;
    controller.updateEvent(
      cat.id,
      event,
      input.on,
      note: input.note,
      kind: input.kind,
    );
    return;
  }
  final sure = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.storyDeleteTitle),
      content: Text(l10n.storyDeleteBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.delete),
        ),
      ],
    ),
  );
  if (sure == true) controller.deleteEvent(event.id);
}

/// Asks for a date as precise as the person knows it (day, month or year,
/// and for a year "around"), never in the future, and an optional note, in
/// words that fit [type].
///
/// With [existing] it changes that entry ("Change the date"); with
/// [offerAnother] too, a small link switches to adding a new entry instead.
class LifeEventDialog extends StatefulWidget {
  const LifeEventDialog({
    super.key,
    required this.type,
    this.sex,
    this.existing,
    this.offerAnother = false,
  });

  final LifeEventType type;

  /// The cat's sex, for the title of a sterilisation.
  final CatSex? sex;
  final LifeEvent? existing;
  final bool offerAnother;

  @override
  State<LifeEventDialog> createState() => _LifeEventDialogState();
}

class _LifeEventDialogState extends State<LifeEventDialog> {
  final _now = DateTime.now();
  late LifeEvent? _editing = widget.existing;
  late final _note = TextEditingController(text: widget.existing?.note ?? '');
  late DatePrecision _precision;
  late bool _around;
  late HealthKind? _kind = widget.existing?.kind;
  int? _year;
  late int _month;
  late int _day;

  @override
  void initState() {
    super.initState();
    _setDate(_editing?.on ?? _defaultDate());
  }

  /// A birth has no sensible default year: the person must pick one.
  bool get _needsYear => widget.type == LifeEventType.born && _editing == null;

  PartialDate? _defaultDate() {
    final roughly =
        widget.type == LifeEventType.born ||
        widget.type == LifeEventType.sterilised;
    if (_needsYear) return null;
    return roughly
        ? PartialDate.year(_now.year, around: true)
        : PartialDate.day(_now.year, _now.month, _now.day);
  }

  /// [d] null: no year yet (a new birth), shown as year, around.
  void _setDate(PartialDate? d) {
    _precision = d?.precision ?? DatePrecision.year;
    _around = d?.around ?? true;
    _year = d?.year;
    _month = d?.month ?? _now.month;
    _day = d?.day ?? _now.day;
    _clamp();
  }

  /// Keeps the chosen parts real and not after today.
  void _clamp() {
    final year = _year;
    if (year != null && year > _now.year) _year = _now.year;
    // With no year yet, any month and day are fine.
    final y = _year ?? _now.year - 1;
    final maxMonth = y == _now.year ? _now.month : 12;
    if (_month > maxMonth) _month = maxMonth;
    var maxDay = DateUtils.getDaysInMonth(y, _month);
    if (y == _now.year && _month == _now.month && _now.day < maxDay) {
      maxDay = _now.day;
    }
    if (_day > maxDay) _day = maxDay;
    if (_precision != DatePrecision.year) _around = false;
  }

  /// The chosen date, or null while a birth still has no year.
  PartialDate? get _date {
    final year = _year;
    if (year == null) return null;
    return switch (_precision) {
      DatePrecision.year => PartialDate.year(year, around: _around),
      DatePrecision.month => PartialDate.month(year, _month),
      DatePrecision.day => PartialDate.day(year, _month, _day),
    };
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Widget _drop(
    String label,
    String id,
    int? value,
    List<int> items,
    String Function(int) text,
    ValueChanged<int> onChanged,
  ) => DropdownButtonFormField<int>(
    key: ValueKey('$id-$value'),
    initialValue: value,
    isExpanded: true,
    decoration: InputDecoration(
      labelText: label,
      isDense: true,
      contentPadding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
    ),
    items: [
      for (final i in items) DropdownMenuItem(value: i, child: Text(text(i))),
    ],
    onChanged: (v) {
      if (v != null) setState(() => onChanged(v));
    },
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final type = widget.type;
    final editing = _editing;
    final title = editing != null && type != LifeEventType.health
        ? l10n.storyChangeDate
        : lifeTypeName(l10n, type, sex: widget.sex);
    final help = switch (type) {
      LifeEventType.missing => l10n.storyMissingHelp,
      LifeEventType.found => l10n.storyFoundHelp,
      LifeEventType.born => l10n.storyBornHelp,
      LifeEventType.sterilised => l10n.storySterilisedHelp,
      LifeEventType.died => l10n.storyDiedHelp,
      LifeEventType.health => l10n.storyHealthHelp,
    };
    final hint = switch (type) {
      LifeEventType.missing => l10n.storyMissingNoteHint,
      LifeEventType.died => l10n.storyNoteHintDied,
      LifeEventType.health => l10n.storyHealthNoteHint,
      _ => null,
    };
    final years = [for (var y = _now.year; y >= PartialDate.minYear; y--) y];
    final y = _year ?? _now.year - 1;
    final maxMonth = y == _now.year ? _now.month : 12;
    final maxDay = y == _now.year && _month == _now.month
        ? _now.day
        : DateUtils.getDaysInMonth(y, _month);
    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(help),
            const SizedBox(height: 16),
            if (type == LifeEventType.health) ...[
              Text(
                l10n.storyHealthKindLabel,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final k in HealthKind.values)
                    ChoiceChip(
                      label: Text(healthKindName(l10n, k)),
                      selected: _kind == k,
                      onSelected: (_) => setState(() => _kind = k),
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            SegmentedButton<DatePrecision>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: DatePrecision.day,
                  label: Text(l10n.storyPrecisionDay),
                ),
                ButtonSegment(
                  value: DatePrecision.month,
                  label: Text(l10n.storyPrecisionMonth),
                ),
                ButtonSegment(
                  value: DatePrecision.year,
                  label: Text(l10n.storyPrecisionYear),
                ),
              ],
              selected: {_precision},
              onSelectionChanged: (s) => setState(() {
                _precision = s.single;
                _clamp();
              }),
            ),
            const SizedBox(height: 12),
            // Day and month share a row; the year has its own, so nothing is
            // squeezed at phone width or with large text.
            if (_precision != DatePrecision.year) ...[
              Row(
                children: [
                  if (_precision == DatePrecision.day) ...[
                    Expanded(
                      flex: 2,
                      child: _drop(
                        l10n.storyDateDay,
                        'day',
                        _day,
                        [for (var d = 1; d <= maxDay; d++) d],
                        (d) => '$d',
                        (v) => _day = v,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    flex: 3,
                    child: _drop(
                      l10n.storyDateMonth,
                      'month',
                      _month,
                      [for (var m = 1; m <= maxMonth; m++) m],
                      (m) => DateFormat.MMMM(locale).format(DateTime(2000, m)),
                      (v) {
                        _month = v;
                        _clamp();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            _drop(l10n.storyDateYear, 'year', _year, years, (y) => '$y', (v) {
              _year = v;
              _clamp();
            }),
            if (_precision == DatePrecision.year)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: FilterChip(
                    label: Text(l10n.storyAround),
                    selected: _around,
                    onSelected: (v) => setState(() => _around = v),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _note,
              maxLength: LifeEventType.maxNoteLength,
              maxLines: 3,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.storyNoteLabel,
                hintText: hint,
              ),
            ),
            if (editing != null && widget.offerAnother)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => setState(() {
                    _editing = null;
                    _note.clear();
                    _setDate(_defaultDate());
                  }),
                  child: Text(l10n.storyAddAnother),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed:
              _date == null || (type == LifeEventType.health && _kind == null)
              ? null
              : () => Navigator.of(context).pop(
                  LifeEventInput(
                    _date!,
                    _note.text,
                    editing,
                    kind: type == LifeEventType.health ? _kind : null,
                  ),
                ),
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

/// A small, warm moment when a missing cat is found. The heart eases in,
/// or just appears when the device asks for reduced motion.
class FoundCelebration extends StatelessWidget {
  const FoundCelebration({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final still = MediaQuery.disableAnimationsOf(context);
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: still ? 1 : 0.4, end: 1),
            duration: still ? Duration.zero : const Duration(milliseconds: 700),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: Icon(
              Icons.favorite,
              size: 64,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name.isEmpty
                ? l10n.storyCelebrationUnnamed
                : l10n.storyCelebrationNamed(name),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.storyCelebrationClose),
        ),
      ],
    );
  }
}
