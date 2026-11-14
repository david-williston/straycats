// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meet_cat_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The camera side of meeting a cat: take a photo, and throw it away if it
/// is not kept. Needs a signed-in person (the cats page keeps that provider
/// alive while it is open). (Keeping it is [CatsController.recordSighting].)

@ProviderFor(MeetCatController)
final meetCatControllerProvider = MeetCatControllerProvider._();

/// The camera side of meeting a cat: take a photo, and throw it away if it
/// is not kept. Needs a signed-in person (the cats page keeps that provider
/// alive while it is open). (Keeping it is [CatsController.recordSighting].)
final class MeetCatControllerProvider
    extends $NotifierProvider<MeetCatController, void> {
  /// The camera side of meeting a cat: take a photo, and throw it away if it
  /// is not kept. Needs a signed-in person (the cats page keeps that provider
  /// alive while it is open). (Keeping it is [CatsController.recordSighting].)
  MeetCatControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'meetCatControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$meetCatControllerHash();

  @$internal
  @override
  MeetCatController create() => MeetCatController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$meetCatControllerHash() => r'528c0e89eadd3bf8b4f10c7fc439544f9d53813b';

/// The camera side of meeting a cat: take a photo, and throw it away if it
/// is not kept. Needs a signed-in person (the cats page keeps that provider
/// alive while it is open). (Keeping it is [CatsController.recordSighting].)

abstract class _$MeetCatController extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
