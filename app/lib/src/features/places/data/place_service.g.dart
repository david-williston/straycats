// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(placeService)
final placeServiceProvider = PlaceServiceProvider._();

final class PlaceServiceProvider
    extends $FunctionalProvider<PlaceService, PlaceService, PlaceService>
    with $Provider<PlaceService> {
  PlaceServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'placeServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$placeServiceHash();

  @$internal
  @override
  $ProviderElement<PlaceService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PlaceService create(Ref ref) {
    return placeService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlaceService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlaceService>(value),
    );
  }
}

String _$placeServiceHash() => r'e7f66694fad472146e65824b741b16e04285e062';

@ProviderFor(placeCapture)
final placeCaptureProvider = PlaceCaptureProvider._();

final class PlaceCaptureProvider
    extends $FunctionalProvider<PlaceCapture, PlaceCapture, PlaceCapture>
    with $Provider<PlaceCapture> {
  PlaceCaptureProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'placeCaptureProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$placeCaptureHash();

  @$internal
  @override
  $ProviderElement<PlaceCapture> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PlaceCapture create(Ref ref) {
    return placeCapture(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlaceCapture value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlaceCapture>(value),
    );
  }
}

String _$placeCaptureHash() => r'2bb3e5e25ac64cfd9086aa2dfae5765a37edc839';
