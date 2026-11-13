import 'dart:developer' as developer;
import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/cats_folder.dart';
import '../data/photo_metadata.dart';
import 'photo_uploader.dart';

part 'photo_privacy_cleaner.g.dart';

/// A one-off task at start-up for photos kept before photos were cleaned:
/// any local photo that still has GPS data is stripped in place and queued
/// to upload again, so the stored copy is replaced by a clean one. Safe to
/// run every start: once a file is clean it is skipped, and the outbox
/// uploads each at most once more.
///
/// Photos that exist only in Storage (no local copy on this phone) are not
/// touched, since that would mean downloading each one; there are none on
/// the owner's phone, which keeps every photo it took.
class PhotoPrivacyCleaner {
  PhotoPrivacyCleaner(this._folder, this._uploader);

  final CatsFolder _folder;
  final PhotoUploader _uploader;

  /// Returns how many photos were cleaned. Never throws.
  Future<int> run() async {
    var cleaned = 0;
    try {
      final dir = await _folder.open();
      for (final f in dir.listSync().whereType<File>()) {
        final name = f.uri.pathSegments.last;
        if (!name.endsWith('.jpg')) continue;
        try {
          if (!await photoHasGps(f)) continue;
          await stripPhotoFile(f);
          await _uploader.enqueue(name.substring(0, name.length - 4));
          cleaned++;
        } catch (e) {
          developer.log('Could not clean $name: $e', name: 'straycats');
        }
      }
    } catch (e) {
      developer.log('Photo clean-up stopped: $e', name: 'straycats');
    }
    return cleaned;
  }
}

@Riverpod(keepAlive: true)
PhotoPrivacyCleaner photoPrivacyCleaner(Ref ref) => PhotoPrivacyCleaner(
  ref.watch(catsFolderProvider),
  ref.watch(photoUploaderProvider),
);
