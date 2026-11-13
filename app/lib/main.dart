import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'src/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    // A failed start shows its message with Retry at once, rather than being
    // retried behind a spinner.
    ProviderScope(retry: (_, _) => null, child: const StrayCatsApp()),
  );
}
