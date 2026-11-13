import 'dart:io';
import 'dart:typed_data';

/// Photos must not carry where they were taken. The camera plugins copy
/// EXIF (including GPS) into the files they return, so every photo is
/// cleaned here, without re-encoding the picture.

class _Segment {
  const _Segment(this.marker, this.start, this.end);
  final int marker;
  final int start; // at the 0xFF
  final int end; // exclusive
}

/// The segments before the image data, then where the data starts. Null if
/// [b] is not a JPEG that can be walked.
(List<_Segment>, int)? _walk(Uint8List b) {
  if (b.length < 4 || b[0] != 0xFF || b[1] != 0xD8) return null;
  final segs = <_Segment>[];
  var i = 2;
  while (i + 1 < b.length) {
    if (b[i] != 0xFF) return null;
    var m = b[i + 1];
    if (m == 0xFF) {
      i++; // fill byte
      continue;
    }
    if (m == 0xDA) return (segs, i); // start of scan: the rest is picture
    if (m == 0x01 || (m >= 0xD0 && m <= 0xD7)) {
      segs.add(_Segment(m, i, i + 2));
      i += 2;
      continue;
    }
    if (i + 3 >= b.length) return null;
    final end = i + 2 + ((b[i + 2] << 8) | b[i + 3]);
    if (end > b.length) return null;
    segs.add(_Segment(m, i, end));
    i = end;
  }
  return null;
}

bool _isExif(Uint8List b, _Segment s) =>
    s.marker == 0xE1 &&
    s.end - s.start >= 10 &&
    b[s.start + 4] == 0x45 && // E x i f
    b[s.start + 5] == 0x78 &&
    b[s.start + 6] == 0x69 &&
    b[s.start + 7] == 0x66;

/// Looks up one IFD0 tag in an Exif segment: its 16/32-bit value, or null.
({int? orientation, bool gps}) _exifFacts(Uint8List b, _Segment s) {
  final tiff = s.start + 10;
  final end = s.end;
  if (tiff + 8 > end) return (orientation: null, gps: false);
  final little = b[tiff] == 0x49;
  int u16(int o) => little ? b[o] | (b[o + 1] << 8) : (b[o] << 8) | b[o + 1];
  int u32(int o) => little
      ? b[o] | (b[o + 1] << 8) | (b[o + 2] << 16) | (b[o + 3] << 24)
      : (b[o] << 24) | (b[o + 1] << 16) | (b[o + 2] << 8) | b[o + 3];
  int? orientation;
  var gps = false;
  final ifd = tiff + u32(tiff + 4);
  if (ifd + 2 > end) return (orientation: null, gps: false);
  final n = u16(ifd);
  for (var k = 0; k < n; k++) {
    final e = ifd + 2 + k * 12;
    if (e + 12 > end) break;
    final tag = u16(e);
    if (tag == 0x0112) orientation = u16(e + 8);
    if (tag == 0x8825) gps = true;
  }
  return (orientation: orientation, gps: gps);
}

/// True if [b] is a JPEG with a GPS block in its Exif data.
bool jpegHasGps(Uint8List b) {
  final walked = _walk(b);
  if (walked == null) return false;
  for (final s in walked.$1) {
    if (_isExif(b, s) && _exifFacts(b, s).gps) return true;
  }
  return false;
}

/// A tiny Exif segment holding only the orientation, so a rotated photo
/// still shows upright.
Uint8List _orientationOnly(int orientation) => Uint8List.fromList([
  0xFF, 0xE1, 0x00, 0x22, 0x45, 0x78, 0x69, 0x66, 0x00, 0x00, //
  0x4D, 0x4D, 0x00, 0x2A, 0x00, 0x00, 0x00, 0x08, //
  0x00, 0x01, 0x01, 0x12, 0x00, 0x03, 0x00, 0x00, 0x00, 0x01,
  orientation >> 8, orientation & 0xFF, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00,
]);

/// [b] without Exif, XMP, IPTC and comments (GPS, time, device, and the
/// like). Only the orientation survives, as a minimal Exif block. The
/// picture itself is not touched. Anything that is not a JPEG is returned
/// unchanged.
Uint8List stripJpegMetadata(Uint8List b) {
  final walked = _walk(b);
  if (walked == null) return b;
  final out = BytesBuilder(copy: false)..add(const [0xFF, 0xD8]);
  var orientationDone = false;
  for (final s in walked.$1) {
    final drop = s.marker == 0xE1 || s.marker == 0xED || s.marker == 0xFE;
    if (!drop) {
      out.add(Uint8List.sublistView(b, s.start, s.end));
      continue;
    }
    if (_isExif(b, s) && !orientationDone) {
      final o = _exifFacts(b, s).orientation;
      if (o != null && o > 1 && o <= 8) {
        out.add(_orientationOnly(o));
        orientationDone = true;
      }
    }
  }
  out.add(Uint8List.sublistView(b, walked.$2));
  return out.toBytes();
}

/// Strips [file] in place. Returns true if it had GPS data. Safe to run
/// again.
Future<bool> stripPhotoFile(File file) async {
  final bytes = await file.readAsBytes();
  final hadGps = jpegHasGps(bytes);
  final clean = stripJpegMetadata(bytes);
  if (clean.length != bytes.length) {
    final tmp = File('${file.path}.strip');
    await tmp.writeAsBytes(clean, flush: true);
    await tmp.rename(file.path);
  }
  return hadGps;
}

/// True if the photo file still has GPS data.
Future<bool> photoHasGps(File file) async =>
    jpegHasGps(await file.readAsBytes());
