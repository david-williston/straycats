// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'is_admin.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the signed-in person is an admin: the ID token's custom claim
/// `admin == true`, refreshed from the server after startup (it runs again
/// after signing in, since the uid may have changed). This only decides what
/// the app shows; the security rules are what keep other people's data safe.

@ProviderFor(isAdmin)
final isAdminProvider = IsAdminProvider._();

/// Whether the signed-in person is an admin: the ID token's custom claim
/// `admin == true`, refreshed from the server after startup (it runs again
/// after signing in, since the uid may have changed). This only decides what
/// the app shows; the security rules are what keep other people's data safe.

final class IsAdminProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether the signed-in person is an admin: the ID token's custom claim
  /// `admin == true`, refreshed from the server after startup (it runs again
  /// after signing in, since the uid may have changed). This only decides what
  /// the app shows; the security rules are what keep other people's data safe.
  IsAdminProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isAdminProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isAdminHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return isAdmin(ref);
  }
}

String _$isAdminHash() => r'372f67d2003ff7bb3dbd5e85fee1eb14281c9430';
