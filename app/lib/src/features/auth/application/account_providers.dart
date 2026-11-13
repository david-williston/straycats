import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/auth_repository.dart';
import '../domain/account.dart';

part 'account_providers.g.dart';

/// The signed-in account, again when it is linked to Google.
@Riverpod(keepAlive: true)
Stream<Account?> account(Ref ref) =>
    ref.watch(authRepositoryProvider).accountChanges();
