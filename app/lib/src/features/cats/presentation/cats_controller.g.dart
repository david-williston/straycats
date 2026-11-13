// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cats_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Every cat, kept up to date by the repository's listener; the screens show
/// it and change it through here.
///
/// Writes are not awaited: Firestore applies them locally at once (the
/// listener shows them) and syncs when it can. A failure is logged, since it
/// means a rules or app bug (`permission-denied`), not a missing connection.

@ProviderFor(CatsController)
final catsControllerProvider = CatsControllerProvider._();

/// Every cat, kept up to date by the repository's listener; the screens show
/// it and change it through here.
///
/// Writes are not awaited: Firestore applies them locally at once (the
/// listener shows them) and syncs when it can. A failure is logged, since it
/// means a rules or app bug (`permission-denied`), not a missing connection.
final class CatsControllerProvider
    extends $StreamNotifierProvider<CatsController, List<Cat>> {
  /// Every cat, kept up to date by the repository's listener; the screens show
  /// it and change it through here.
  ///
  /// Writes are not awaited: Firestore applies them locally at once (the
  /// listener shows them) and syncs when it can. A failure is logged, since it
  /// means a rules or app bug (`permission-denied`), not a missing connection.
  CatsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'catsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$catsControllerHash();

  @$internal
  @override
  CatsController create() => CatsController();
}

String _$catsControllerHash() => r'c4c4e0f3573b36749e4cb8fce49966a514287f0f';

/// Every cat, kept up to date by the repository's listener; the screens show
/// it and change it through here.
///
/// Writes are not awaited: Firestore applies them locally at once (the
/// listener shows them) and syncs when it can. A failure is logged, since it
/// means a rules or app bug (`permission-denied`), not a missing connection.

abstract class _$CatsController extends $StreamNotifier<List<Cat>> {
  Stream<List<Cat>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Cat>>, List<Cat>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Cat>>, List<Cat>>,
              AsyncValue<List<Cat>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
