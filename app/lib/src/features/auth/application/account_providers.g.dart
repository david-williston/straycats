// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The signed-in account, again when it is linked to Google.

@ProviderFor(account)
final accountProvider = AccountProvider._();

/// The signed-in account, again when it is linked to Google.

final class AccountProvider
    extends
        $FunctionalProvider<AsyncValue<Account?>, Account?, Stream<Account?>>
    with $FutureModifier<Account?>, $StreamProvider<Account?> {
  /// The signed-in account, again when it is linked to Google.
  AccountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountHash();

  @$internal
  @override
  $StreamProviderElement<Account?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Account?> create(Ref ref) {
    return account(ref);
  }
}

String _$accountHash() => r'581f96b83653438578c6a3e62e1f0654b205cd46';
