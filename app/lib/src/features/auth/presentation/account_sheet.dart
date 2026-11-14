import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../localization/app_localizations.dart';
import '../../admin/data/is_admin.dart';
import '../../admin/presentation/people_page.dart';
import '../application/account_providers.dart';
import '../application/sign_in_service.dart';
import '../application/sign_out_service.dart';
import '../domain/account.dart';

/// The app bar button that opens the account sheet.
class AccountButton extends StatelessWidget {
  const AccountButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.account_circle_outlined),
      tooltip: AppLocalizations.of(context).account,
      onPressed: () => showAccountSheet(context),
    );
  }
}

/// Opens the account sheet.
Future<void> showAccountSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const AccountSheet(),
    );

/// Who you are signed in as, Google sign-in to keep the cats safe and,
/// for an admin, the way to the People list.
class AccountSheet extends ConsumerStatefulWidget {
  const AccountSheet({super.key});

  @override
  ConsumerState<AccountSheet> createState() => _AccountSheetState();
}

class _AccountSheetState extends ConsumerState<AccountSheet> {
  bool _busy = false;

  /// Something is actually running (not waiting on the person): shows the
  /// progress indicator.
  bool _working = false;

  Future<void> _signIn() async {
    setState(() => _busy = _working = true);
    final result = await ref
        .read(signInServiceProvider)
        .signInWithGoogle(
          l10n: AppLocalizations.of(context),
          messenger: ScaffoldMessenger.of(context),
          mounted: () => mounted,
          onSwitched: () => Navigator.of(context).pop(),
        );
    // After switching, the sheet closes itself and stays busy until then.
    if (mounted && result != GoogleSignInResult.switchedAccount) {
      setState(() => _busy = _working = false);
    }
  }

  Future<void> _signOut() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final service = ref.read(signOutServiceProvider);
    setState(() => _busy = _working = true);
    try {
      final pending = await service.pendingUploads();
      if (!mounted) return;
      // The dialog is waiting for the person, not working.
      setState(() => _working = false);
      final choice = await showDialog<_SignOutChoice>(
        context: context,
        builder: (_) => _SignOutDialog(pending: pending),
      );
      if (!mounted) return;
      if (choice != null) setState(() => _working = true);
      switch (choice) {
        case null:
          setState(() => _busy = _working = false);
        case _SignOutChoice.wait:
          final left = await service.uploadPending();
          if (!mounted) return;
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                left == 0 ? l10n.uploadsDone : l10n.uploadsStillWaiting,
              ),
            ),
          );
          setState(() => _busy = _working = false);
        case _SignOutChoice.signOut:
          await service.signOut();
          // The app starts again as a new anonymous user.
          if (navigator.mounted) navigator.pop();
      }
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.signOutFailed)));
      if (mounted) setState(() => _busy = _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final account = ref.watch(accountProvider).value;
    final isAdmin = ref.watch(isAdminProvider).value ?? false;
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
            // Signing in or out can take seconds: show that it is working.
            if (_working)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: LinearProgressIndicator(),
              ),
            if (signedIn) ...[
              Text(l10n.signedInAs(who)),
              if (account.email != null && account.email != who)
                Text(
                  account.email!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : _signOut,
                  icon: _working ? const _Spinner() : const Icon(Icons.logout),
                  label: Text(l10n.signOut),
                ),
              ),
            ] else ...[
              Text(l10n.accountNotSignedIn),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _busy ? null : _signIn,
                icon: _working ? const _Spinner() : const Icon(Icons.login),
                label: Text(l10n.signInWithGoogle),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.accountKeepSafeHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 16),
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

class _Spinner extends StatelessWidget {
  const _Spinner();

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 18,
    height: 18,
    child: CircularProgressIndicator(strokeWidth: 2),
  );
}

enum _SignOutChoice { signOut, wait }

/// Asks before signing out. With photos still uploading it offers to wait.
class _SignOutDialog extends StatelessWidget {
  const _SignOutDialog({required this.pending});

  final int pending;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    void pop(_SignOutChoice? c) => Navigator.of(context).pop(c);
    return AlertDialog(
      title: Text(l10n.signOutTitle),
      content: Text(
        pending > 0 ? l10n.signOutPendingBody(pending) : l10n.signOutBody,
      ),
      actions: pending > 0
          ? [
              TextButton(
                onPressed: () => pop(_SignOutChoice.signOut),
                child: Text(l10n.signOutAnyway),
              ),
              FilledButton(
                onPressed: () => pop(_SignOutChoice.wait),
                child: Text(l10n.signOutWait),
              ),
            ]
          : [
              TextButton(onPressed: () => pop(null), child: Text(l10n.cancel)),
              FilledButton(
                onPressed: () => pop(_SignOutChoice.signOut),
                child: Text(l10n.signOut),
              ),
            ],
    );
  }
}
