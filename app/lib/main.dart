import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app.dart';

void main() {
  runApp(
    // A failed load shows "Could not open the cats folder" at once, rather
    // than being retried behind a spinner.
    ProviderScope(retry: (_, _) => null, child: const StrayCatsApp()),
  );
}
