// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'people_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(peopleRepository)
final peopleRepositoryProvider = PeopleRepositoryProvider._();

final class PeopleRepositoryProvider
    extends
        $FunctionalProvider<
          PeopleRepository,
          PeopleRepository,
          PeopleRepository
        >
    with $Provider<PeopleRepository> {
  PeopleRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'peopleRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$peopleRepositoryHash();

  @$internal
  @override
  $ProviderElement<PeopleRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PeopleRepository create(Ref ref) {
    return peopleRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PeopleRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PeopleRepository>(value),
    );
  }
}

String _$peopleRepositoryHash() => r'4343039ace6da1f29022f7487a67e7c53a74304b';

@ProviderFor(people)
final peopleProvider = PeopleProvider._();

final class PeopleProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Person>>,
          List<Person>,
          FutureOr<List<Person>>
        >
    with $FutureModifier<List<Person>>, $FutureProvider<List<Person>> {
  PeopleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'peopleProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$peopleHash();

  @$internal
  @override
  $FutureProviderElement<List<Person>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Person>> create(Ref ref) {
    return people(ref);
  }
}

String _$peopleHash() => r'a0270d1986036c9b900d45896c31d94145a2e8be';

@ProviderFor(personCats)
final personCatsProvider = PersonCatsFamily._();

final class PersonCatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Cat>>,
          List<Cat>,
          FutureOr<List<Cat>>
        >
    with $FutureModifier<List<Cat>>, $FutureProvider<List<Cat>> {
  PersonCatsProvider._({
    required PersonCatsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'personCatsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$personCatsHash();

  @override
  String toString() {
    return r'personCatsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Cat>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Cat>> create(Ref ref) {
    final argument = this.argument as String;
    return personCats(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PersonCatsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$personCatsHash() => r'0be2138d23b3ae0dd70ee2c01a2a524fae5afa38';

final class PersonCatsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Cat>>, String> {
  PersonCatsFamily._()
    : super(
        retry: null,
        name: r'personCatsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PersonCatsProvider call(String uid) =>
      PersonCatsProvider._(argument: uid, from: this);

  @override
  String toString() => r'personCatsProvider';
}
