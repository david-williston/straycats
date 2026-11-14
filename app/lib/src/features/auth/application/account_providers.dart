import 'package:flutter_riverpod/flutter_riverpod.dart' show Provider;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/auth_repository.dart';
import '../domain/account.dart';

part 'account_providers.g.dart';

/// The signed-in account, again when it is linked to Google.
@Riverpod(keepAlive: true)
Stream<Account?> account(Ref ref) =>
    ref.watch(authRepositoryProvider).accountChanges();

/// True when the person is signed in with Google. Photographing cats needs it.
final signedInProvider = Provider<bool>((ref) {
  final account = ref.watch(accountProvider).value;
  return account != null && !account.isAnonymous;
});
