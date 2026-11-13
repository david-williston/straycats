import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../localization/app_localizations.dart';
import '../../cats/application/cat_importer.dart';
import '../../cats/data/legacy_cats_reader.dart';
import '../../cats/presentation/cats_page.dart';
import '../application/app_startup.dart';

/// Shows a quiet loading state while the app signs in and brings the old
/// cats over, or what went wrong with Retry, and then the cats.
class AppStartupWidget extends ConsumerWidget {
  const AppStartupWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startup = ref.watch(appStartupProvider);
    final l10n = AppLocalizations.of(context);
    return startup.when(
      skipLoadingOnReload: false,
      data: (_) => const CatsPage(),
      loading: () => _Message(text: l10n.startupLoading, busy: true),
      error: (error, _) => _Message(
        text: switch (error) {
          SignInFailed() => l10n.firstLaunchNeedsInternet,
          ImportOffline() => l10n.importNeedsInternet,
          LegacyCatsCorrupt() => l10n.importFailed,
          _ => l10n.startupFailed,
        },
        onRetry: () => ref.invalidate(appStartupProvider),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, this.busy = false, this.onRetry});

  final String text;
  final bool busy;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipOval(
                child: Image.asset(
                  'assets/icon/icon.png',
                  width: 96,
                  height: 96,
                  excludeFromSemantics: true,
                ),
              ),
              const SizedBox(height: 24),
              if (busy) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
              ],
              Text(
                text,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: busy
                      ? Theme.of(context).colorScheme.onSurfaceVariant
                      : null,
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 16),
                FilledButton(onPressed: onRetry, child: Text(l10n.retry)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
