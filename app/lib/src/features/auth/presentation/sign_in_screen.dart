import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../localization/app_localizations.dart';
import '../../cats/presentation/cats_controller.dart';
import '../../settings/presentation/language_picker.dart';
import '../application/sign_in_service.dart';
import '../domain/account.dart';

/// What signed-out people see: the logo, a warm line and one way in.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  bool _busy = false;

  Future<void> _signIn() async {
    setState(() => _busy = true);
    final result = await ref
        .read(signInServiceProvider)
        .signInWithGoogle(
          l10n: AppLocalizations.of(context),
          messenger: ScaffoldMessenger.of(context),
          mounted: () => mounted,
        );
    // After switching, the app starts again and replaces this screen.
    if (mounted && result != GoogleSignInResult.switchedAccount) {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    // Not shown, but loaded: signing in says whether cats were left behind.
    ref.watch(catsControllerProvider);
    return Scaffold(
      appBar: AppBar(actions: const [LanguageButton()]),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // The logo from the website's home page, which carries the name.
              Image.asset(
                'assets/images/straycats-logo.png',
                height: 240,
                semanticLabel: l10n.appTitle,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.welcomeLine,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 40),
              FilledButton.icon(
                onPressed: _busy ? null : _signIn,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
                icon: const Icon(Icons.login),
                label: Text(l10n.signInWithGoogle),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
