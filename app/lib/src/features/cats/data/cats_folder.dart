import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../startup/application/app_startup.dart';

part 'cats_folder.g.dart';

/// One person's local photo store and upload outbox on this phone:
/// `<documents>/users/<uid>/photos/` and `<documents>/users/<uid>/outbox/`.
/// One folder per uid, so one account's photos never show for, or upload
/// under, another. It starts empty; photos come back from Storage on demand.
class CatsFolder {
  /// [dir] is the photo store; [outboxDir] defaults to `outbox/` inside it.
  CatsFolder({required this.dir, this.outboxDir});

  /// The folder of [uid] under [documents].
  factory CatsFolder.forUser(
    Future<Directory> Function() documents,
    String uid,
  ) {
    if (uid.isEmpty || uid.contains('/') || uid.contains('..')) {
      throw ArgumentError.value(uid, 'uid', 'Not a safe folder name');
    }
    Future<Directory> sub(String name) async =>
        Directory('${(await documents()).path}/users/$uid/$name');
    return CatsFolder(dir: () => sub('photos'), outboxDir: () => sub('outbox'));
  }

  final Future<Directory> Function() dir;
  final Future<Directory> Function()? outboxDir;
  String _path = '';

  /// The photo folder, created if needed. Throws if it cannot be made.
  Future<Directory> open() async {
    final folder = await (await dir()).create(recursive: true);
    _path = folder.path;
    return folder;
  }

  /// The outbox folder, created if needed.
  Future<Directory> openOutbox() async {
    final custom = outboxDir;
    if (custom != null) return (await custom()).create(recursive: true);
    return Directory('${(await open()).path}/outbox').create();
  }

  /// A file in the folder. The folder is opened before any photo is shown.
  File file(String name) => File('$_path/$name');
}

/// Where the phone keeps app files; tests override it with a temp folder.
@Riverpod(keepAlive: true)
Future<Directory> Function() documentsDir(Ref ref) =>
    getApplicationDocumentsDirectory;

/// The signed-in person's folder. It changes with the uid, so everything
/// built on it (photos, outbox, uploader) starts over for the new account.
@Riverpod(keepAlive: true)
CatsFolder catsFolder(Ref ref) =>
    CatsFolder.forUser(ref.watch(documentsDirProvider), ref.watch(uidProvider));
