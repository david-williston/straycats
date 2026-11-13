import 'package:flutter/material.dart';

import '../cat.dart';
import '../cat_store.dart';
import '../l10n/app_localizations.dart';
import '../matching.dart';
import '../widgets/cat_tile.dart';
import 'cat_card.dart';
import 'who_is_this_page.dart';

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
    final l10n = AppLocalizations.of(context);
    final cats = _cats == null ? null : byLastSeen(_cats!);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: _failed
          ? Center(child: Text(l10n.cantOpenCatsFolder))
          : cats == null
          ? const SizedBox.shrink()
          : cats.isEmpty
          ? Center(child: Text(l10n.noCatsYet))
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
        tooltip: l10n.meetACat,
        child: const Icon(Icons.photo_camera),
      ),
    );
  }
}
