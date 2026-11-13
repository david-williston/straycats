import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/cats_folder.dart';
import '../data/photo_outbox.dart';
import '../data/photo_storage.dart';

part 'photo_uploader.g.dart';

/// Uploads the photos in the outbox. On a failure it stops and tries again
/// later: when started, for each new photo, on app resume, and every
/// [interval] while the app is in the foreground. Uploading again after a
/// crash is harmless, since Storage overwrites.
class PhotoUploader with WidgetsBindingObserver {
  PhotoUploader(
    this._folder,
    this._outbox,
    this._storage, {
    this.interval = const Duration(minutes: 5),
  });

  final CatsFolder _folder;
  final PhotoOutbox _outbox;
  final PhotoStorage _storage;

  /// Null means no periodic retry (for tests).
  final Duration? interval;

  Timer? _timer;
  bool _started = false;
  Future<void>? _draining;

  /// Begins draining, and keeps trying until [stop].
  void start() {
    if (_started) return;
    _started = true;
    WidgetsBinding.instance.addObserver(this);
    _schedule();
    unawaited(drain());
  }

  void stop() {
    _started = false;
    _timer?.cancel();
    _timer = null;
    WidgetsBinding.instance.removeObserver(this);
  }

  void _schedule() {
    final every = interval;
    if (every == null) return;
    _timer?.cancel();
    _timer = Timer.periodic(every, (_) => unawaited(drain()));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _schedule();
      unawaited(drain());
    } else if (state == AppLifecycleState.paused) {
      _timer?.cancel();
      _timer = null;
    }
  }

  /// Marks [photoId] for upload and tries at once. Returns when the marker
  /// is written, not when the upload ends.
  Future<void> enqueue(String photoId) async {
    await _outbox.enqueue(photoId);
    unawaited(drain());
  }

  /// Uploads everything waiting, one at a time. Calls while one is running
  /// share it.
  Future<void> drain() =>
      _draining ??= _drain().whenComplete(() => _draining = null);

  Future<void> _drain() async {
    try {
      final dir = await _folder.open();
      for (final id in await _outbox.pending()) {
        final file = File('${dir.path}/$id.jpg');
        if (!file.existsSync()) {
          developer.log('Photo $id is gone, dropped', name: 'straycats');
          await _outbox.remove(id);
          continue;
        }
        await _storage.upload(id, file);
        await _outbox.remove(id);
      }
    } catch (e) {
      developer.log('Upload stopped, will retry: $e', name: 'straycats');
    }
  }
}

@Riverpod(keepAlive: true)
PhotoUploader photoUploader(Ref ref) {
  final folder = ref.watch(catsFolderProvider);
  final uploader = PhotoUploader(
    folder,
    PhotoOutbox(folder),
    ref.watch(photoStorageProvider),
  );
  ref.onDispose(uploader.stop);
  return uploader;
}
