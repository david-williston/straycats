import 'dart:io';

import 'package:flutter/material.dart';

/// A photo from the cats folder, with a placeholder if it cannot be shown.
class CatPhoto extends StatelessWidget {
  const CatPhoto(
    this.file, {
    super.key,
    this.fit = BoxFit.cover,
    this.cacheWidth,
  });

  final File? file;
  final BoxFit fit;
  final int? cacheWidth;

  @override
  Widget build(BuildContext context) {
    const broken = Center(child: Icon(Icons.broken_image));
    final file = this.file;
    if (file == null) return broken;
    return Image.file(
      file,
      fit: fit,
      cacheWidth: cacheWidth,
      errorBuilder: (_, _, _) => broken,
    );
  }
}
