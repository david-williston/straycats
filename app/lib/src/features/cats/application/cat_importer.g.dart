// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cat_importer.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(catImporter)
final catImporterProvider = CatImporterProvider._();

final class CatImporterProvider
    extends $FunctionalProvider<CatImporter, CatImporter, CatImporter>
    with $Provider<CatImporter> {
  CatImporterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'catImporterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$catImporterHash();

  @$internal
  @override
  $ProviderElement<CatImporter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CatImporter create(Ref ref) {
    return catImporter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CatImporter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CatImporter>(value),
    );
  }
}

String _$catImporterHash() => r'7ca2954075b94db64853b34e47a4132f4cfc5b9b';
