import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(const StrayCatsApp());

/// Lists the saved cat photos, newest first. Returns an empty list if the
/// folder (or the platform plugin) is unavailable.
Future<List<File>> loadCats() async {
  try {
    final dir = await _catsDir();
    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.toLowerCase().endsWith('.jpg'))
        .toList()
      ..sort((a, b) => b.path.compareTo(a.path));
    return files;
  } catch (_) {
    return [];
  }
}

Future<Directory> _catsDir() async {
  final docs = await getApplicationDocumentsDirectory();
  return Directory('${docs.path}/cats').create(recursive: true);
}

Future<void> meetCat() async {
  final shot = await ImagePicker().pickImage(source: ImageSource.camera);
  if (shot == null) return;
  final dir = await _catsDir();
  final stamp = DateTime.now().millisecondsSinceEpoch;
  await File(shot.path).copy('${dir.path}/$stamp.jpg');
}

class StrayCatsApp extends StatelessWidget {
  const StrayCatsApp({super.key, this.load = loadCats, this.capture = meetCat});

  final Future<List<File>> Function() load;
  final Future<void> Function() capture;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stray Cats',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
      ),
      home: CatsPage(load: load, capture: capture),
    );
  }
}

class CatsPage extends StatefulWidget {
  const CatsPage({super.key, required this.load, required this.capture});

  final Future<List<File>> Function() load;
  final Future<void> Function() capture;

  @override
  State<CatsPage> createState() => _CatsPageState();
}

class _CatsPageState extends State<CatsPage> {
  List<File>? _cats;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final cats = await widget.load();
    if (mounted) setState(() => _cats = cats);
  }

  Future<void> _meet() async {
    await widget.capture();
    await _refresh();
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
                  ),
                  itemCount: cats.length,
                  itemBuilder: (context, i) => GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => Scaffold(
                          appBar: AppBar(),
                          body: Center(
                            child: InteractiveViewer(
                              child: Image.file(cats[i]),
                            ),
                          ),
                        ),
                      ),
                    ),
                    child: Image.file(
                      cats[i],
                      fit: BoxFit.cover,
                      cacheWidth: 600,
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
