// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'language_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The language the user chose, or null to follow the phone.

@ProviderFor(LanguageController)
final languageControllerProvider = LanguageControllerProvider._();

/// The language the user chose, or null to follow the phone.
final class LanguageControllerProvider
    extends $AsyncNotifierProvider<LanguageController, Locale?> {
  /// The language the user chose, or null to follow the phone.
  LanguageControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'languageControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$languageControllerHash();

  @$internal
  @override
  LanguageController create() => LanguageController();
}

String _$languageControllerHash() =>
    r'ab2cf0798aa704158388d524c11ae8575e2d1e66';

/// The language the user chose, or null to follow the phone.

abstract class _$LanguageController extends $AsyncNotifier<Locale?> {
  FutureOr<Locale?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Locale?>, Locale?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Locale?>, Locale?>,
              AsyncValue<Locale?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
