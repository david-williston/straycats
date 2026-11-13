import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';

part 'card_sharer.g.dart';

/// Hands a finished card image to the phone's share sheet. The image is
/// made on the device and written to the app's cache folder; nothing is
/// uploaded and no link is made.
class CardSharer {
  CardSharer({
    Future<Directory> Function()? cacheDir,
    Future<void> Function(String path)? send,
    DateTime Function()? now,
  }) : _cacheDir = cacheDir ?? getTemporaryDirectory,
       _send = send ?? _shareSheet,
       _now = now ?? DateTime.now;

  final Future<Directory> Function() _cacheDir;
  final Future<void> Function(String path) _send;
  final DateTime Function() _now;

  static const _prefix = 'cat-card-';

  static Future<void> _shareSheet(String path) async {
    await SharePlus.instance.share(
      ShareParams(files: [XFile(path, mimeType: 'image/png')]),
    );
  }

  /// Writes [png] to the cache folder (first deleting earlier cards) and
  /// opens the share sheet with it. Returns the file.
  Future<File> share(Uint8List png) async {
    final file = await write(png);
    await _send(file.path);
    return file;
  }

  /// Deletes old card files, then writes [png] as a new one.
  Future<File> write(Uint8List png) async {
    final dir = await (await _cacheDir()).create(recursive: true);
    await deleteOld(dir);
    final stamp = _now().millisecondsSinceEpoch;
    return File('${dir.path}/$_prefix$stamp.png')
        .writeAsBytes(png, flush: true);
  }

  /// Removes every earlier card file in [dir].
  Future<void> deleteOld(Directory dir) async {
    await for (final f in dir.list()) {
      final name = f.uri.pathSegments.last;
      if (f is File && name.startsWith(_prefix) && name.endsWith('.png')) {
        try {
          await f.delete();
        } on FileSystemException {
          // Still open in the share sheet; the next share clears it.
        }
      }
    }
  }
}

@Riverpod(keepAlive: true)
CardSharer cardSharer(Ref ref) => CardSharer();
