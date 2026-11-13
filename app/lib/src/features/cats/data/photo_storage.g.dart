// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_storage.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(photoStorage)
final photoStorageProvider = PhotoStorageProvider._();

final class PhotoStorageProvider
    extends $FunctionalProvider<PhotoStorage, PhotoStorage, PhotoStorage>
    with $Provider<PhotoStorage> {
  PhotoStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'photoStorageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$photoStorageHash();

  @$internal
  @override
  $ProviderElement<PhotoStorage> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PhotoStorage create(Ref ref) {
    return photoStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PhotoStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PhotoStorage>(value),
    );
  }
}

String _$photoStorageHash() => r'0cf0a892f4b902925de1b23b4bf3d7d4a9ddc7cc';
