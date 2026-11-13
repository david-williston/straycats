// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_privacy_cleaner.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(photoPrivacyCleaner)
final photoPrivacyCleanerProvider = PhotoPrivacyCleanerProvider._();

final class PhotoPrivacyCleanerProvider
    extends
        $FunctionalProvider<
          PhotoPrivacyCleaner,
          PhotoPrivacyCleaner,
          PhotoPrivacyCleaner
        >
    with $Provider<PhotoPrivacyCleaner> {
  PhotoPrivacyCleanerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'photoPrivacyCleanerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$photoPrivacyCleanerHash();

  @$internal
  @override
  $ProviderElement<PhotoPrivacyCleaner> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PhotoPrivacyCleaner create(Ref ref) {
    return photoPrivacyCleaner(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PhotoPrivacyCleaner value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PhotoPrivacyCleaner>(value),
    );
  }
}

String _$photoPrivacyCleanerHash() =>
    r'93a9176fddfcb5d7fe9f3fe800176a55cbf20dbf';
