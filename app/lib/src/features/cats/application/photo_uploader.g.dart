// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_uploader.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(photoUploader)
final photoUploaderProvider = PhotoUploaderProvider._();

final class PhotoUploaderProvider
    extends $FunctionalProvider<PhotoUploader, PhotoUploader, PhotoUploader>
    with $Provider<PhotoUploader> {
  PhotoUploaderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'photoUploaderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$photoUploaderHash();

  @$internal
  @override
  $ProviderElement<PhotoUploader> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PhotoUploader create(Ref ref) {
    return photoUploader(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PhotoUploader value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PhotoUploader>(value),
    );
  }
}

String _$photoUploaderHash() => r'72648502ab5fd1e42ce086bc9d4506282f7a8fc7';
