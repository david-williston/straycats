// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_in_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(signInService)
final signInServiceProvider = SignInServiceProvider._();

final class SignInServiceProvider
    extends $FunctionalProvider<SignInService, SignInService, SignInService>
    with $Provider<SignInService> {
  SignInServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signInServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signInServiceHash();

  @$internal
  @override
  $ProviderElement<SignInService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SignInService create(Ref ref) {
    return signInService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SignInService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SignInService>(value),
    );
  }
}

String _$signInServiceHash() => r'b20fbe6443c3e01b96503d5ca0dd1d3d338bc015';
