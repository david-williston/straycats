import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../localization/app_localizations.dart';
import '../../admin/data/is_admin.dart';
import '../../admin/presentation/people_page.dart';
import '../../cats/presentation/cats_controller.dart';
import '../../profile/data/profile_repository.dart';
import '../../startup/application/app_startup.dart';
import '../application/account_providers.dart';
import '../data/auth_repository.dart';
import '../domain/account.dart';

/// The app bar button that opens the account sheet.
class AccountButton extends StatelessWidget {
  const AccountButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.account_circle_outlined),
      tooltip: AppLocalizations.of(context).account,
      onPressed: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => const AccountSheet(),
      ),
    );
  }
}

/// Who you are signed in as, Google sign-in to keep the cats safe, the
/// optional nickname and, for an admin, the way to the People list.
class AccountSheet extends ConsumerStatefulWidget {
  const AccountSheet({super.key});

  @override
  ConsumerState<AccountSheet> createState() => _AccountSheetState();
}

class _AccountSheetState extends ConsumerState<AccountSheet> {
  final _nickname = TextEditingController();
  bool _nicknameLoaded = false;
  bool _busy = false;

  @override
  void dispose() {
    _nickname.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final hadCats =
        (ref.read(catsControllerProvider).value ?? const []).isNotEmpty;
    // Kept now: the sheet's ref stops working once the sheet is gone.
    final container = ProviderScope.containerOf(context);
    setState(() => _busy = true);
    try {
      final result = await ref.read(authRepositoryProvider).signInWithGoogle();
      if (!mounted) return;
      switch (result) {
        case GoogleSignInResult.cancelled:
          setState(() => _busy = false);
          return;
        case GoogleSignInResult.linked:
          container.invalidate(isAdminProvider);
          messenger.showSnackBar(SnackBar(content: Text(l10n.googleLinked)));
          setState(() => _busy = false);
        case GoogleSignInResult.switchedAccount:
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                hadCats ? l10n.googleSwitchedKeptOld : l10n.googleSwitched,
              ),
            ),
          );
          Navigator.of(context).pop();
          // A new uid: start again so every screen reads the new account.
          container.invalidate(appStartupProvider);
      }
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.signInFailed)));
      setState(() => _busy = false);
    }
  }

  Future<void> _saveNickname() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final uid = ref.read(uidProvider);
    try {
      // Not awaited past the local write: offline it waits for the server.
      final write = ref
          .read(profileRepositoryProvider)
          .setNickname(uid, _nickname.text);
      FocusScope.of(context).unfocus();
      messenger.showSnackBar(SnackBar(content: Text(l10n.nicknameSaved)));
      await write;
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.nicknameNotSaved)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final account = ref.watch(accountProvider).value;
    final isAdmin = ref.watch(isAdminProvider).value ?? false;
    final nickname = ref.watch(myNicknameProvider);
    if (!_nicknameLoaded && nickname.hasValue) {
      _nicknameLoaded = true;
      _nickname.text = nickname.value ?? '';
    }
    final signedIn = account != null && !account.isAnonymous;
    final who = account?.displayName?.isNotEmpty == true
        ? account!.displayName!
        : account?.email ?? '';
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.account, style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            if (signedIn) ...[
              Text(l10n.signedInAs(who)),
              if (account.email != null && account.email != who)
                Text(
                  account.email!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ] else ...[
              Text(l10n.accountNotSignedIn),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _busy ? null : _signIn,
                icon: const Icon(Icons.login),
                label: Text(l10n.signInWithGoogle),
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _nickname,
              maxLength: maxNicknameLength,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: l10n.nicknameOptional,
                hintText: l10n.nicknameHint,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.check),
                  tooltip: l10n.save,
                  onPressed: _saveNickname,
                ),
              ),
              onSubmitted: (_) => _saveNickname(),
            ),
            if (isAdmin)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                leading: const Icon(Icons.groups_outlined),
                title: Text(l10n.people),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  final navigator = Navigator.of(context)..pop();
                  navigator.push(
                    MaterialPageRoute<void>(builder: (_) => const PeoplePage()),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
