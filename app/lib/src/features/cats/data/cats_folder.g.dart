// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cats_folder.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Where the phone keeps app files; tests override it with a temp folder.

@ProviderFor(documentsDir)
final documentsDirProvider = DocumentsDirProvider._();

/// Where the phone keeps app files; tests override it with a temp folder.

final class DocumentsDirProvider
    extends
        $FunctionalProvider<
          Future<Directory> Function(),
          Future<Directory> Function(),
          Future<Directory> Function()
        >
    with $Provider<Future<Directory> Function()> {
  /// Where the phone keeps app files; tests override it with a temp folder.
  DocumentsDirProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'documentsDirProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$documentsDirHash();

  @$internal
  @override
  $ProviderElement<Future<Directory> Function()> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Future<Directory> Function() create(Ref ref) {
    return documentsDir(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Future<Directory> Function() value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Future<Directory> Function()>(value),
    );
  }
}

String _$documentsDirHash() => r'8400bcf56aa47ef0808f9640a9ffdb8c84eb98e6';

/// The signed-in person's folder. It changes with the uid, so everything
/// built on it (photos, outbox, uploader) starts over for the new account.

@ProviderFor(catsFolder)
final catsFolderProvider = CatsFolderProvider._();

/// The signed-in person's folder. It changes with the uid, so everything
/// built on it (photos, outbox, uploader) starts over for the new account.

final class CatsFolderProvider
    extends $FunctionalProvider<CatsFolder, CatsFolder, CatsFolder>
    with $Provider<CatsFolder> {
  /// The signed-in person's folder. It changes with the uid, so everything
  /// built on it (photos, outbox, uploader) starts over for the new account.
  CatsFolderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'catsFolderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$catsFolderHash();

  @$internal
  @override
  $ProviderElement<CatsFolder> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CatsFolder create(Ref ref) {
    return catsFolder(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CatsFolder value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CatsFolder>(value),
    );
  }
}

String _$catsFolderHash() => r'9c4885710cdf497267f561322d04ecdc1b929387';
