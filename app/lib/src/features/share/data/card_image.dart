import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

/// Draws [boundary] to PNG bytes with no metadata. The pixels are read raw
/// and encoded fresh, so nothing from the cat's photo (EXIF, GPS) can come
/// along, and [stripPngMetadata] then drops every chunk that is not image
/// data, whatever the encoder wrote.
Future<Uint8List> renderCardPng(
  RenderRepaintBoundary boundary, {
  double pixelRatio = 1,
}) async {
  final image = await boundary.toImage(pixelRatio: pixelRatio);
  try {
    final raw = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (raw == null) throw StateError('Could not read the card pixels');
    final png = await _encode(raw, image.width, image.height);
    return stripPngMetadata(png);
  } finally {
    image.dispose();
  }
}

Future<Uint8List> _encode(ByteData raw, int width, int height) async {
  final buffer = await ui.ImmutableBuffer.fromUint8List(
    raw.buffer.asUint8List(raw.offsetInBytes, raw.lengthInBytes),
  );
  final descriptor = ui.ImageDescriptor.raw(
    buffer,
    width: width,
    height: height,
    pixelFormat: ui.PixelFormat.rgba8888,
  );
  final codec = await descriptor.instantiateCodec();
  final frame = await codec.getNextFrame();
  final bytes = await frame.image.toByteData(format: ui.ImageByteFormat.png);
  frame.image.dispose();
  codec.dispose();
  descriptor.dispose();
  buffer.dispose();
  if (bytes == null) throw StateError('Could not encode the card');
  return bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
}

/// The only PNG chunks kept: the header, palette, transparency, pixel data
/// and the end. Text, EXIF, colour-profile and every other ancillary chunk
/// is dropped.
const _keptChunks = {'IHDR', 'PLTE', 'tRNS', 'IDAT', 'IEND'};

/// [png] with every chunk but the image data's removed.
Uint8List stripPngMetadata(Uint8List png) {
  const signatureLength = 8;
  final out = BytesBuilder(copy: false)
    ..add(Uint8List.sublistView(png, 0, signatureLength));
  final data = ByteData.sublistView(png);
  var i = signatureLength;
  while (i + 12 <= png.length) {
    final length = data.getUint32(i);
    final type = String.fromCharCodes(png.sublist(i + 4, i + 8));
    final end = i + 12 + length;
    if (end > png.length) break;
    if (_keptChunks.contains(type)) out.add(png.sublist(i, end));
    i = end;
  }
  return out.toBytes();
}

/// The chunk types of [png], in order (for tests and checks).
List<String> pngChunkTypes(Uint8List png) {
  final data = ByteData.sublistView(png);
  final types = <String>[];
  var i = 8;
  while (i + 12 <= png.length) {
    types.add(String.fromCharCodes(png.sublist(i + 4, i + 8)));
    i += 12 + data.getUint32(i);
  }
  return types;
}
