import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../cat.dart';
import '../l10n/app_localizations.dart';
import '../l10n/encounter_labels.dart';
import '../widgets/cat_photo.dart';

/// The cat card: a photo large (pinch to zoom), its name, and every
/// encounter newest first (tap one to show its photo). Calls [onClose] with
/// the trimmed name when the card closes; submitting the field closes it.
class CatCard extends StatefulWidget {
  const CatCard({
    super.key,
    required this.cat,
    required this.photoFile,
    required this.onClose,
  });

  final Cat cat;
  final File Function(String name) photoFile;
  final void Function(String name) onClose;

  @override
  State<CatCard> createState() => _CatCardState();
}

class _CatCardState extends State<CatCard> {
  late final _name = TextEditingController(text: widget.cat.name);
  late final _history = widget.cat.history;
  int _shown = 0;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    return PopScope(
      onPopInvokedWithResult: (_, _) => widget.onClose(_name.text.trim()),
      child: Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            Expanded(
              child: InteractiveViewer(
                child: CatPhoto(
                  _history.isEmpty
                      ? null
                      : widget.photoFile(_history[_shown].photo),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: l10n.name,
                  hintText: l10n.giveCatAName,
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: (_) => Navigator.of(context).pop(),
              ),
            ),
            SizedBox(
              height: 150,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: _history.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final e = _history[i];
                  return GestureDetector(
                    onTap: () => setState(() => _shown = i),
                    child: SizedBox(
                      width: 96,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 96,
                            height: 72,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 2,
                                color: i == _shown
                                    ? theme.colorScheme.primary
                                    : Colors.transparent,
                              ),
                            ),
                            child: CatPhoto(
                              widget.photoFile(e.photo),
                              cacheWidth: 200,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat.yMMMd(locale).format(e.time),
                            style: theme.textTheme.bodySmall,
                          ),
                          if (e.type != null)
                            Text(
                              e.type!.label(l10n),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
