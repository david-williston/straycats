import 'dart:io';

import 'cats_folder.dart';

/// Empty marker files in the person's outbox folder, one per photo still to upload.
/// They survive an app restart, which the SDK's own uploads do not.
class PhotoOutbox {
  PhotoOutbox(this._folder);

  final CatsFolder _folder;

  Future<Directory> _dir() => _folder.openOutbox();

  Future<void> enqueue(String photoId) async {
    await File('${(await _dir()).path}/$photoId').create();
  }

  Future<void> remove(String photoId) async {
    final marker = File('${(await _dir()).path}/$photoId');
    if (marker.existsSync()) await marker.delete();
  }

  /// The photo ids waiting, oldest id first.
  Future<List<String>> pending() async {
    final ids = [
      for (final f in (await _dir()).listSync().whereType<File>())
        f.uri.pathSegments.last,
    ]..sort();
    return ids;
  }
}
