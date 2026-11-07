import 'dart:io';

import 'package:flutter/material.dart';

import 'cat_store.dart' as store;

void main() => runApp(const StrayCatsApp());

class StrayCatsApp extends StatelessWidget {
  const StrayCatsApp({
    super.key,
    this.load = store.loadCats,
    this.capture = store.meetCat,
    this.loadNames = store.loadNames,
    this.saveNames = store.saveNames,
  });

  final Future<List<File>> Function() load;
  final Future<void> Function() capture;
  final Future<Map<String, String>> Function() loadNames;
  final Future<void> Function(Map<String, String>) saveNames;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stray Cats',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
      ),
      home: CatsPage(
        load: load,
        capture: capture,
        loadNames: loadNames,
        saveNames: saveNames,
      ),
    );
  }
}

class CatsPage extends StatefulWidget {
  const CatsPage({
    super.key,
    required this.load,
    required this.capture,
    required this.loadNames,
    required this.saveNames,
  });

  final Future<List<File>> Function() load;
  final Future<void> Function() capture;
  final Future<Map<String, String>> Function() loadNames;
  final Future<void> Function(Map<String, String>) saveNames;

  @override
  State<CatsPage> createState() => _CatsPageState();
}

class _CatsPageState extends State<CatsPage> {
  List<File>? _cats;
  Map<String, String> _names = {};

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final cats = await widget.load();
    final names = await widget.loadNames();
    if (mounted) {
      setState(() {
        _cats = cats;
        _names = names;
      });
    }
  }

  Future<void> _meet() async {
    await widget.capture();
    await _refresh();
  }

  /// Opens the cat card; its name is saved when the card closes.
  void _open(File photo) {
    final key = store.photoKey(photo);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CatCard(
          photo: photo,
          name: _names[key] ?? '',
          onClose: (name) => _rename(key, name),
        ),
      ),
    );
  }

  Future<void> _rename(String key, String name) async {
    if (name == (_names[key] ?? '')) return;
    setState(() => name.isEmpty ? _names.remove(key) : _names[key] = name);
    await widget.saveNames(_names);
  }

  @override
  Widget build(BuildContext context) {
    final cats = _cats;
    return Scaffold(
      appBar: AppBar(title: const Text('Stray Cats')),
      body: cats == null
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
                child: CatTile(
                  photo: cats[i],
                  name: _names[store.photoKey(cats[i])],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _meet,
        tooltip: 'Meet a cat',
        child: const Icon(Icons.photo_camera),
      ),
    );
  }
}

/// A grid tile: the photo with the cat's name (or a quiet hint) beneath.
class CatTile extends StatelessWidget {
  const CatTile({super.key, required this.photo, this.name});

  final File photo;
  final String? name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final named = name != null && name!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Image.file(
            photo,
            fit: BoxFit.cover,
            cacheWidth: 600,
            errorBuilder: (_, _, _) => const Icon(Icons.broken_image),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          named ? name! : 'No name yet',
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

/// The cat card: the photo large (pinch to zoom) and its name. Calls
/// [onClose] with the trimmed name when the card closes; submitting the
/// field closes it.
class CatCard extends StatefulWidget {
  const CatCard({
    super.key,
    required this.photo,
    required this.name,
    required this.onClose,
  });

  final File photo;
  final String name;
  final void Function(String name) onClose;

  @override
  State<CatCard> createState() => _CatCardState();
}

class _CatCardState extends State<CatCard> {
  late final _name = TextEditingController(text: widget.name);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (_, _) => widget.onClose(_name.text.trim()),
      child: Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            Expanded(
              child: InteractiveViewer(
                child: Center(child: Image.file(widget.photo)),
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
          ],
        ),
      ),
    );
  }
}
