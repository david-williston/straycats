import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/data/auth_repository.dart';
import '../../startup/application/app_startup.dart';

part 'is_admin.g.dart';

/// Whether the signed-in person is an admin: the ID token's custom claim
/// `admin == true`, refreshed from the server after startup (it runs again
/// after signing in, since the uid may have changed). This only decides what
/// the app shows; the security rules are what keep other people's data safe.
@Riverpod(keepAlive: true)
Future<bool> isAdmin(Ref ref) async {
  await ref.watch(appStartupProvider.future);
  return ref.watch(authRepositoryProvider).isAdmin(forceRefresh: true);
}
