// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cats_folder.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(catsFolder)
final catsFolderProvider = CatsFolderProvider._();

final class CatsFolderProvider
    extends $FunctionalProvider<CatsFolder, CatsFolder, CatsFolder>
    with $Provider<CatsFolder> {
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

String _$catsFolderHash() => r'6c27f2c3a9224d3e414dacd82276c26b30e44523';
