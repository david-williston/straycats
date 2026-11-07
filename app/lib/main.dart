import 'dart:io';

import 'package:flutter/material.dart';

import 'cat.dart';
import 'cat_store.dart';
import 'matching.dart';

void main() => runApp(StrayCatsApp(store: DeviceCatStore()));

class StrayCatsApp extends StatelessWidget {
  const StrayCatsApp({super.key, required this.store});

  final CatStore store;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stray Cats',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
      ),
      home: CatsPage(store: store),
    );
  }
}

class CatsPage extends StatefulWidget {
  const CatsPage({super.key, required this.store});

  final CatStore store;

  @override
  State<CatsPage> createState() => _CatsPageState();
}

class _CatsPageState extends State<CatsPage> {
  List<Cat>? _cats;
  bool _failed = false;

  CatStore get _store => widget.store;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final cats = await _store.load();
      if (mounted) setState(() => _cats = cats);
    } catch (_) {
      // Nothing is saved after a failed load, so cats.json stays untouched.
      if (mounted) setState(() => _failed = true);
    }
  }

  /// Takes a photo, asks who it is, and records the encounter. Backing out
  /// of "Who is this?" throws the photo away.
  Future<void> _meet() async {
    final cats = _cats;
    if (cats == null) return;
    final photo = await _store.takePhoto();
    if (photo == null || !mounted) return;
    final sighting = await Navigator.of(context).push<Sighting>(
      MaterialPageRoute(
        builder: (_) => WhoIsThisPage(
          photo: photo,
          candidates: findMatches(photo, cats),
          photoFile: _store.photoFile,
        ),
      ),
    );
    if (sighting == null) {
      await _store.discard(photo);
      return;
    }
    final id = photoName(photo).split('.').first;
    final encounter = Encounter(
      id: id,
      photo: photoName(photo),
      time: photoTime(photo),
      type: sighting.type,
    );
    setState(() {
      final cat = sighting.cat;
      if (cat != null) {
        cat.encounters.add(encounter);
      } else {
        cats.add(Cat(id: id, name: sighting.name, encounters: [encounter]));
      }
    });
    await _store.save(cats);
  }

  /// Opens the cat card; its name is saved when the card closes.
  void _open(Cat cat) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CatCard(
          cat: cat,
          photoFile: _store.photoFile,
          onClose: (name) => _rename(cat, name),
        ),
      ),
    );
  }

  Future<void> _rename(Cat cat, String name) async {
    if (name == cat.name) return;
    setState(() => cat.name = name);
    await _store.save(_cats!);
  }

  @override
  Widget build(BuildContext context) {
    final cats = _cats == null ? null : byLastSeen(_cats!);
    return Scaffold(
      appBar: AppBar(title: const Text('Stray Cats')),
      body: _failed
          ? const Center(child: Text('Could not open the cats folder.'))
          : cats == null
          ? const SizedBox.shrink()
          : cats.isEmpty
          ? const Center(
              child: Text('No cats yet. Tap the camera to meet one.'),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.85,
              ),
              itemCount: cats.length,
              itemBuilder: (context, i) => GestureDetector(
                onTap: () => _open(cats[i]),
                child: CatTile(cat: cats[i], photoFile: _store.photoFile),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _cats == null ? null : _meet,
        tooltip: 'Meet a cat',
        child: const Icon(Icons.photo_camera),
      ),
    );
  }
}

/// A photo from the cats folder, with a placeholder if it cannot be shown.
class CatPhoto extends StatelessWidget {
  const CatPhoto(
    this.file, {
    super.key,
    this.fit = BoxFit.cover,
    this.cacheWidth,
  });

  final File? file;
  final BoxFit fit;
  final int? cacheWidth;

  @override
  Widget build(BuildContext context) {
    const broken = Center(child: Icon(Icons.broken_image));
    final file = this.file;
    if (file == null) return broken;
    return Image.file(
      file,
      fit: fit,
      cacheWidth: cacheWidth,
      errorBuilder: (_, _, _) => broken,
    );
  }
}

/// A grid tile: the cat's latest photo with its name (or a quiet hint)
/// beneath.
class CatTile extends StatelessWidget {
  const CatTile({super.key, required this.cat, required this.photoFile});

  final Cat cat;
  final File Function(String name) photoFile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
          named ? cat.name : 'No name yet',
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
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Give this cat a name',
                  border: OutlineInputBorder(),
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
                            formatDate(e.time),
                            style: theme.textTheme.bodySmall,
                          ),
                          if (e.type != null)
                            Text(
                              e.type!.label,
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

/// The answer from "Who is this?": an existing [cat], or a new cat (null)
/// with an optional [name]; and what was happening, if anything.
class Sighting {
  const Sighting({this.cat, this.name = '', this.type});

  final Cat? cat;
  final String name;
  final EncounterType? type;
}

/// Shown after taking a photo: pick the cat (or "New cat"), then optionally
/// what was happening, then Done. Pops with a [Sighting], or null if the
/// user backs out.
class WhoIsThisPage extends StatefulWidget {
  const WhoIsThisPage({
    super.key,
    required this.photo,
    required this.candidates,
    required this.photoFile,
  });

  final File photo;
  final List<Cat> candidates;
  final File Function(String name) photoFile;

  @override
  State<WhoIsThisPage> createState() => _WhoIsThisPageState();
}

class _WhoIsThisPageState extends State<WhoIsThisPage> {
  final _name = TextEditingController();
  bool _picked = false;
  Cat? _cat;
  EncounterType? _type;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _pick(Cat? cat) => setState(() {
    _picked = true;
    _cat = cat;
  });

  void _done() =>
      Navigator.of(context)
          .pop(Sighting(cat: _cat, name: _name.text.trim(), type: _type));

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Back from the second step returns to the first.
      canPop: !_picked,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _picked = false);
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_picked ? _title : 'Who is this?')),
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
                ? FilledButton(onPressed: _done, child: const Text('Done'))
                : FilledButton.icon(
                    onPressed: () => _pick(null),
                    icon: const Icon(Icons.add),
                    label: const Text('New cat'),
                  ),
          ),
        ),
      ),
    );
  }

  String get _title {
    final cat = _cat;
    if (cat == null) return 'New cat';
    return cat.name.isEmpty ? 'This cat' : cat.name;
  }

  List<Widget> _choices(BuildContext context) {
    if (widget.candidates.isEmpty) {
      return const [Text('No cats yet. This one will be the first.')];
    }
    return [
      Text(
        'Is it one of these?',
        style: Theme.of(context).textTheme.titleMedium,
      ),
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
          child: CatTile(
            cat: widget.candidates[i],
            photoFile: widget.photoFile,
          ),
        ),
      ),
    ];
  }

  List<Widget> _details(BuildContext context) {
    return [
      if (_cat == null) ...[
        TextField(
          controller: _name,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Name (optional)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
      ],
      Text(
        'What was happening? (optional)',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final type in EncounterType.values)
            ChoiceChip(
              label: Text(type.label),
              selected: _type == type,
              onSelected: (on) => setState(() => _type = on ? type : null),
            ),
        ],
      ),
    ];
  }
}

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// A short date, e.g. `7 Nov 2026`.
String formatDate(DateTime t) => '${t.day} ${_months[t.month - 1]} ${t.year}';
