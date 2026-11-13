// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'matching_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(matchingService)
final matchingServiceProvider = MatchingServiceProvider._();

final class MatchingServiceProvider
    extends
        $FunctionalProvider<MatchingService, MatchingService, MatchingService>
    with $Provider<MatchingService> {
  MatchingServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'matchingServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$matchingServiceHash();

  @$internal
  @override
  $ProviderElement<MatchingService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MatchingService create(Ref ref) {
    return matchingService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MatchingService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MatchingService>(value),
    );
  }
}

String _$matchingServiceHash() => r'ad4d47f4c0235864e0a4804f68f9fa5c6bc53fde';
