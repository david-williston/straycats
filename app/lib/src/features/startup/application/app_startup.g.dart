// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_startup.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// What must happen before the app shows the cats: sign in anonymously (once),
/// bring over the cats kept before Firebase (once), and start the photo
/// uploader. It also starts creating the profile `users/{uid}`, without
/// waiting (offline, the write waits for a connection). Completes with the
/// user's uid; errors show on the startup screen with Retry.

@ProviderFor(appStartup)
final appStartupProvider = AppStartupProvider._();

/// What must happen before the app shows the cats: sign in anonymously (once),
/// bring over the cats kept before Firebase (once), and start the photo
/// uploader. It also starts creating the profile `users/{uid}`, without
/// waiting (offline, the write waits for a connection). Completes with the
/// user's uid; errors show on the startup screen with Retry.

final class AppStartupProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// What must happen before the app shows the cats: sign in anonymously (once),
  /// bring over the cats kept before Firebase (once), and start the photo
  /// uploader. It also starts creating the profile `users/{uid}`, without
  /// waiting (offline, the write waits for a connection). Completes with the
  /// user's uid; errors show on the startup screen with Retry.
  AppStartupProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appStartupProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appStartupHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return appStartup(ref);
  }
}

String _$appStartupHash() => r'8da5919c110af9e2ef2157fe41249158ca6f3462';

/// The signed-in user's id. Only valid once [appStartup] has completed, which
/// the startup screen guarantees before anything else is built.

@ProviderFor(uid)
final uidProvider = UidProvider._();

/// The signed-in user's id. Only valid once [appStartup] has completed, which
/// the startup screen guarantees before anything else is built.

final class UidProvider extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// The signed-in user's id. Only valid once [appStartup] has completed, which
  /// the startup screen guarantees before anything else is built.
  UidProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'uidProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$uidHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return uid(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$uidHash() => r'7856562b4583e7379ccd2d1cec3a91ddce456944';
