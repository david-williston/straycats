import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../localization/app_localizations.dart';
import '../domain/cat.dart';
import '../domain/cat_status.dart';
import 'cat_status_badge.dart';
import 'cats_controller.dart';

/// On the cat card: the status badge with its note, and (unless [readOnly],
/// as for an admin) a Status button for marking the cat as missing, found
/// or remembered, or back to normal. The record stays open whatever the
/// status. Where a cat was seen is never asked for here: the note is a few
/// free words.
class CatStatusSection extends ConsumerWidget {
  const CatStatusSection({super.key, required this.cat, this.readOnly = false});

  final Cat cat;
  final bool readOnly;

  Future<void> _choose(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final status = cat.status;
    final choice = await showModalBottomSheet<CatStatus>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (status == CatStatus.missing)
              ListTile(
                leading: const Icon(Icons.celebration_outlined),
                title: Text(l10n.statusMarkFound),
                onTap: () => Navigator.of(context).pop(CatStatus.found),
              ),
            if (status != CatStatus.missing && status != CatStatus.remembered)
              ListTile(
                leading: const Icon(Icons.search),
                title: Text(l10n.statusMarkMissing),
                onTap: () => Navigator.of(context).pop(CatStatus.missing),
              ),
            if (status != CatStatus.remembered)
              ListTile(
                leading: const Icon(Icons.favorite_border),
                title: Text(l10n.statusRemember),
                onTap: () => Navigator.of(context).pop(CatStatus.remembered),
              ),
            if (status != CatStatus.known)
              ListTile(
                leading: const Icon(Icons.undo),
                title: Text(l10n.statusBackToNormal),
                onTap: () => Navigator.of(context).pop(CatStatus.known),
              ),
          ],
        ),
      ),
    );
    if (choice == null || !context.mounted) return;
    final controller = ref.read(catsControllerProvider.notifier);
    if (choice == CatStatus.known) {
      final sure = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.statusBackToNormal),
          content: Text(l10n.statusBackToNormalBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.statusBackToNormal),
            ),
          ],
        ),
      );
      if (sure == true) controller.setStatus(cat.id, CatStatus.known);
      return;
    }
    final result = await showDialog<_StatusInput>(
      context: context,
      builder: (context) => _StatusDialog(choice),
    );
    if (result == null) return;
    controller.setStatus(cat.id, choice, since: result.date, note: result.note);
    if (choice == CatStatus.found && context.mounted) {
      await showDialog<void>(
        context: context,
        builder: (context) => _Celebration(name: cat.name),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final hasStatus = cat.status != CatStatus.known;
    if (readOnly && !hasStatus) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: hasStatus
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CatStatusBadge(cat: cat),
                      if (cat.statusNote.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4, left: 4),
                          child: Text(
                            cat.statusNote,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
          if (!readOnly)
            TextButton.icon(
              onPressed: () => _choose(context, ref),
              icon: const Icon(Icons.flag_outlined),
              label: Text(l10n.statusButton),
            ),
        ],
      ),
    );
  }
}

class _StatusInput {
  const _StatusInput(this.date, this.note);

  final DateTime date;
  final String note;
}

/// Asks for a date (today unless changed, never in the future) and an
/// optional note, in words that fit [status].
class _StatusDialog extends StatefulWidget {
  const _StatusDialog(this.status);

  final CatStatus status;

  @override
  State<_StatusDialog> createState() => _StatusDialogState();
}

class _StatusDialogState extends State<_StatusDialog> {
  final _note = TextEditingController();
  late DateTime _date = _today();

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: _today(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final (
      title,
      help,
      dateLabel,
      noteLabel,
      noteHint,
    ) = switch (widget.status) {
      CatStatus.missing => (
        l10n.statusMarkMissing,
        l10n.statusMissingHelp,
        l10n.statusMissingDate,
        l10n.statusMissingNoteLabel,
        l10n.statusMissingNoteHint,
      ),
      CatStatus.found => (
        l10n.statusMarkFound,
        l10n.statusFoundHelp,
        l10n.statusFoundDate,
        l10n.statusFoundNoteLabel,
        null,
      ),
      _ => (
        l10n.statusRemember,
        l10n.statusRememberHelp,
        l10n.statusRememberDate,
        l10n.statusRememberNoteLabel,
        null,
      ),
    };
    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(help),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pick,
              icon: const Icon(Icons.calendar_today_outlined),
              label: Text(
                '$dateLabel: ${DateFormat.yMMMd(locale).format(_date)}',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _note,
              maxLength: CatStatus.maxNoteLength,
              maxLines: 3,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: noteLabel,
                hintText: noteHint,
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
          onPressed: () =>
              Navigator.of(context).pop(_StatusInput(_date, _note.text)),
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

/// A small, warm moment when a missing cat is found. The heart eases in,
/// or just appears when the device asks for reduced motion.
class _Celebration extends StatelessWidget {
  const _Celebration({required this.name});

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
                ? l10n.statusCelebrationUnnamed
                : l10n.statusCelebrationNamed(name),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.statusCelebrationClose),
        ),
      ],
    );
  }
}
