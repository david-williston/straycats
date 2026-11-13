import 'dart:io';

/// A photo's file name, e.g. `1730.jpg`.
String photoName(File photo) => photo.uri.pathSegments.last;

/// The time a photo was taken, from its `<millis>.jpg` file name. Falls back
/// to the file's modified time if the name is not a number.
DateTime photoTime(File photo) {
  final stem = photoName(photo).split('.').first;
  final millis = int.tryParse(stem);
  if (millis != null) return DateTime.fromMillisecondsSinceEpoch(millis);
  try {
    return photo.lastModifiedSync();
  } catch (_) {
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}
