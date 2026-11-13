// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_out_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(signOutService)
final signOutServiceProvider = SignOutServiceProvider._();

final class SignOutServiceProvider
    extends $FunctionalProvider<SignOutService, SignOutService, SignOutService>
    with $Provider<SignOutService> {
  SignOutServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signOutServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signOutServiceHash();

  @$internal
  @override
  $ProviderElement<SignOutService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SignOutService create(Ref ref) {
    return signOutService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SignOutService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SignOutService>(value),
    );
  }
}

String _$signOutServiceHash() => r'2f41eca6d1f9a79da31723c22eb8f710895b7651';
