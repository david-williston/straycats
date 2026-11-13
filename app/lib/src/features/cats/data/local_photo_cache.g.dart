// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_photo_cache.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(localPhotoCache)
final localPhotoCacheProvider = LocalPhotoCacheProvider._();

final class LocalPhotoCacheProvider
    extends
        $FunctionalProvider<LocalPhotoCache, LocalPhotoCache, LocalPhotoCache>
    with $Provider<LocalPhotoCache> {
  LocalPhotoCacheProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localPhotoCacheProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localPhotoCacheHash();

  @$internal
  @override
  $ProviderElement<LocalPhotoCache> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LocalPhotoCache create(Ref ref) {
    return localPhotoCache(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalPhotoCache value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalPhotoCache>(value),
    );
  }
}

String _$localPhotoCacheHash() => r'fdf1ef4224691f331abb3c89ee206d91d395e8f7';

/// The file for an encounter's photo, or null for the placeholder.

@ProviderFor(photoFile)
final photoFileProvider = PhotoFileFamily._();

/// The file for an encounter's photo, or null for the placeholder.

final class PhotoFileProvider
    extends $FunctionalProvider<AsyncValue<File?>, File?, FutureOr<File?>>
    with $FutureModifier<File?>, $FutureProvider<File?> {
  /// The file for an encounter's photo, or null for the placeholder.
  PhotoFileProvider._({
    required PhotoFileFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'photoFileProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$photoFileHash();

  @override
  String toString() {
    return r'photoFileProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<File?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<File?> create(Ref ref) {
    final argument = this.argument as String;
    return photoFile(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PhotoFileProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$photoFileHash() => r'5dbb45e7708df219205282b5576d4544026d242d';

/// The file for an encounter's photo, or null for the placeholder.

final class PhotoFileFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<File?>, String> {
  PhotoFileFamily._()
    : super(
        retry: null,
        name: r'photoFileProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The file for an encounter's photo, or null for the placeholder.

  PhotoFileProvider call(String photoId) =>
      PhotoFileProvider._(argument: photoId, from: this);

  @override
  String toString() => r'photoFileProvider';
}
