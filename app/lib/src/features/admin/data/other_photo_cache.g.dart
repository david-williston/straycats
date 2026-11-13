// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'other_photo_cache.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(otherPhotoCache)
final otherPhotoCacheProvider = OtherPhotoCacheProvider._();

final class OtherPhotoCacheProvider
    extends
        $FunctionalProvider<OtherPhotoCache, OtherPhotoCache, OtherPhotoCache>
    with $Provider<OtherPhotoCache> {
  OtherPhotoCacheProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'otherPhotoCacheProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$otherPhotoCacheHash();

  @$internal
  @override
  $ProviderElement<OtherPhotoCache> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OtherPhotoCache create(Ref ref) {
    return otherPhotoCache(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OtherPhotoCache value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OtherPhotoCache>(value),
    );
  }
}

String _$otherPhotoCacheHash() => r'd4440c376460f2d4fbbf9f0c181004ac60c0cc51';

/// The file for a photo owned by [ownerUid], or null for the placeholder.

@ProviderFor(ownerPhotoFile)
final ownerPhotoFileProvider = OwnerPhotoFileFamily._();

/// The file for a photo owned by [ownerUid], or null for the placeholder.

final class OwnerPhotoFileProvider
    extends $FunctionalProvider<AsyncValue<File?>, File?, FutureOr<File?>>
    with $FutureModifier<File?>, $FutureProvider<File?> {
  /// The file for a photo owned by [ownerUid], or null for the placeholder.
  OwnerPhotoFileProvider._({
    required OwnerPhotoFileFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'ownerPhotoFileProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$ownerPhotoFileHash();

  @override
  String toString() {
    return r'ownerPhotoFileProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<File?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<File?> create(Ref ref) {
    final argument = this.argument as (String, String);
    return ownerPhotoFile(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is OwnerPhotoFileProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$ownerPhotoFileHash() => r'7772dff8b059fad0466566e2b3f6ecc5eb9bc474';

/// The file for a photo owned by [ownerUid], or null for the placeholder.

final class OwnerPhotoFileFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<File?>, (String, String)> {
  OwnerPhotoFileFamily._()
    : super(
        retry: null,
        name: r'ownerPhotoFileProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The file for a photo owned by [ownerUid], or null for the placeholder.

  OwnerPhotoFileProvider call(String ownerUid, String photoId) =>
      OwnerPhotoFileProvider._(argument: (ownerUid, photoId), from: this);

  @override
  String toString() => r'ownerPhotoFileProvider';
}
