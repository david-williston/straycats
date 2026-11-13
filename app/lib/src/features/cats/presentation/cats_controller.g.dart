// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cats_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Every cat, loaded once; the screens show it and change it through here.
///
/// A failed load is an error state and nothing is saved after it, so a
/// failed load can never overwrite the stored cats.

@ProviderFor(CatsController)
final catsControllerProvider = CatsControllerProvider._();

/// Every cat, loaded once; the screens show it and change it through here.
///
/// A failed load is an error state and nothing is saved after it, so a
/// failed load can never overwrite the stored cats.
final class CatsControllerProvider
    extends $AsyncNotifierProvider<CatsController, List<Cat>> {
  /// Every cat, loaded once; the screens show it and change it through here.
  ///
  /// A failed load is an error state and nothing is saved after it, so a
  /// failed load can never overwrite the stored cats.
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

String _$catsControllerHash() => r'b068bac4391d7d771ae80a5f87cc5ff4b7191cdf';

/// Every cat, loaded once; the screens show it and change it through here.
///
/// A failed load is an error state and nothing is saved after it, so a
/// failed load can never overwrite the stored cats.

abstract class _$CatsController extends $AsyncNotifier<List<Cat>> {
  FutureOr<List<Cat>> build();
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
