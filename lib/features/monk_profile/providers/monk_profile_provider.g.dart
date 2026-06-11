// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monk_profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$monkDetailHash() => r'5bc27e742a33f62eedfbdfdaba86de6608161401';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [monkDetail].
@ProviderFor(monkDetail)
const monkDetailProvider = MonkDetailFamily();

/// See also [monkDetail].
class MonkDetailFamily extends Family<AsyncValue<Monk>> {
  /// See also [monkDetail].
  const MonkDetailFamily();

  /// See also [monkDetail].
  MonkDetailProvider call(
    String monkId,
  ) {
    return MonkDetailProvider(
      monkId,
    );
  }

  @override
  MonkDetailProvider getProviderOverride(
    covariant MonkDetailProvider provider,
  ) {
    return call(
      provider.monkId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'monkDetailProvider';
}

/// See also [monkDetail].
class MonkDetailProvider extends AutoDisposeFutureProvider<Monk> {
  /// See also [monkDetail].
  MonkDetailProvider(
    String monkId,
  ) : this._internal(
          (ref) => monkDetail(
            ref as MonkDetailRef,
            monkId,
          ),
          from: monkDetailProvider,
          name: r'monkDetailProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$monkDetailHash,
          dependencies: MonkDetailFamily._dependencies,
          allTransitiveDependencies:
              MonkDetailFamily._allTransitiveDependencies,
          monkId: monkId,
        );

  MonkDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.monkId,
  }) : super.internal();

  final String monkId;

  @override
  Override overrideWith(
    FutureOr<Monk> Function(MonkDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MonkDetailProvider._internal(
        (ref) => create(ref as MonkDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        monkId: monkId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Monk> createElement() {
    return _MonkDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MonkDetailProvider && other.monkId == monkId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, monkId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin MonkDetailRef on AutoDisposeFutureProviderRef<Monk> {
  /// The parameter `monkId` of this provider.
  String get monkId;
}

class _MonkDetailProviderElement extends AutoDisposeFutureProviderElement<Monk>
    with MonkDetailRef {
  _MonkDetailProviderElement(super.provider);

  @override
  String get monkId => (origin as MonkDetailProvider).monkId;
}

String _$monkServicesHash() => r'405d4c372d423b401bb577798decd8b486af95b2';

/// See also [monkServices].
@ProviderFor(monkServices)
const monkServicesProvider = MonkServicesFamily();

/// See also [monkServices].
class MonkServicesFamily extends Family<AsyncValue<List<MonkService>>> {
  /// See also [monkServices].
  const MonkServicesFamily();

  /// See also [monkServices].
  MonkServicesProvider call(
    String monkId,
  ) {
    return MonkServicesProvider(
      monkId,
    );
  }

  @override
  MonkServicesProvider getProviderOverride(
    covariant MonkServicesProvider provider,
  ) {
    return call(
      provider.monkId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'monkServicesProvider';
}

/// See also [monkServices].
class MonkServicesProvider
    extends AutoDisposeFutureProvider<List<MonkService>> {
  /// See also [monkServices].
  MonkServicesProvider(
    String monkId,
  ) : this._internal(
          (ref) => monkServices(
            ref as MonkServicesRef,
            monkId,
          ),
          from: monkServicesProvider,
          name: r'monkServicesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$monkServicesHash,
          dependencies: MonkServicesFamily._dependencies,
          allTransitiveDependencies:
              MonkServicesFamily._allTransitiveDependencies,
          monkId: monkId,
        );

  MonkServicesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.monkId,
  }) : super.internal();

  final String monkId;

  @override
  Override overrideWith(
    FutureOr<List<MonkService>> Function(MonkServicesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MonkServicesProvider._internal(
        (ref) => create(ref as MonkServicesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        monkId: monkId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<MonkService>> createElement() {
    return _MonkServicesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MonkServicesProvider && other.monkId == monkId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, monkId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin MonkServicesRef on AutoDisposeFutureProviderRef<List<MonkService>> {
  /// The parameter `monkId` of this provider.
  String get monkId;
}

class _MonkServicesProviderElement
    extends AutoDisposeFutureProviderElement<List<MonkService>>
    with MonkServicesRef {
  _MonkServicesProviderElement(super.provider);

  @override
  String get monkId => (origin as MonkServicesProvider).monkId;
}

String _$monkScheduleHash() => r'9333face6493d9337eb69102490c7041a7076130';

/// See also [monkSchedule].
@ProviderFor(monkSchedule)
const monkScheduleProvider = MonkScheduleFamily();

/// See also [monkSchedule].
class MonkScheduleFamily extends Family<AsyncValue<List<DayAvailability>>> {
  /// See also [monkSchedule].
  const MonkScheduleFamily();

  /// See also [monkSchedule].
  MonkScheduleProvider call(
    String monkId,
  ) {
    return MonkScheduleProvider(
      monkId,
    );
  }

  @override
  MonkScheduleProvider getProviderOverride(
    covariant MonkScheduleProvider provider,
  ) {
    return call(
      provider.monkId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'monkScheduleProvider';
}

/// See also [monkSchedule].
class MonkScheduleProvider
    extends AutoDisposeFutureProvider<List<DayAvailability>> {
  /// See also [monkSchedule].
  MonkScheduleProvider(
    String monkId,
  ) : this._internal(
          (ref) => monkSchedule(
            ref as MonkScheduleRef,
            monkId,
          ),
          from: monkScheduleProvider,
          name: r'monkScheduleProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$monkScheduleHash,
          dependencies: MonkScheduleFamily._dependencies,
          allTransitiveDependencies:
              MonkScheduleFamily._allTransitiveDependencies,
          monkId: monkId,
        );

  MonkScheduleProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.monkId,
  }) : super.internal();

  final String monkId;

  @override
  Override overrideWith(
    FutureOr<List<DayAvailability>> Function(MonkScheduleRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MonkScheduleProvider._internal(
        (ref) => create(ref as MonkScheduleRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        monkId: monkId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<DayAvailability>> createElement() {
    return _MonkScheduleProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MonkScheduleProvider && other.monkId == monkId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, monkId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin MonkScheduleRef on AutoDisposeFutureProviderRef<List<DayAvailability>> {
  /// The parameter `monkId` of this provider.
  String get monkId;
}

class _MonkScheduleProviderElement
    extends AutoDisposeFutureProviderElement<List<DayAvailability>>
    with MonkScheduleRef {
  _MonkScheduleProviderElement(super.provider);

  @override
  String get monkId => (origin as MonkScheduleProvider).monkId;
}

String _$monkReviewsHash() => r'8bb927122aa38e640a530ed1c8131dc2ec62602c';

/// See also [monkReviews].
@ProviderFor(monkReviews)
const monkReviewsProvider = MonkReviewsFamily();

/// See also [monkReviews].
class MonkReviewsFamily extends Family<AsyncValue<List<MonkReview>>> {
  /// See also [monkReviews].
  const MonkReviewsFamily();

  /// See also [monkReviews].
  MonkReviewsProvider call(
    String monkId,
  ) {
    return MonkReviewsProvider(
      monkId,
    );
  }

  @override
  MonkReviewsProvider getProviderOverride(
    covariant MonkReviewsProvider provider,
  ) {
    return call(
      provider.monkId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'monkReviewsProvider';
}

/// See also [monkReviews].
class MonkReviewsProvider extends AutoDisposeFutureProvider<List<MonkReview>> {
  /// See also [monkReviews].
  MonkReviewsProvider(
    String monkId,
  ) : this._internal(
          (ref) => monkReviews(
            ref as MonkReviewsRef,
            monkId,
          ),
          from: monkReviewsProvider,
          name: r'monkReviewsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$monkReviewsHash,
          dependencies: MonkReviewsFamily._dependencies,
          allTransitiveDependencies:
              MonkReviewsFamily._allTransitiveDependencies,
          monkId: monkId,
        );

  MonkReviewsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.monkId,
  }) : super.internal();

  final String monkId;

  @override
  Override overrideWith(
    FutureOr<List<MonkReview>> Function(MonkReviewsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MonkReviewsProvider._internal(
        (ref) => create(ref as MonkReviewsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        monkId: monkId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<MonkReview>> createElement() {
    return _MonkReviewsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MonkReviewsProvider && other.monkId == monkId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, monkId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin MonkReviewsRef on AutoDisposeFutureProviderRef<List<MonkReview>> {
  /// The parameter `monkId` of this provider.
  String get monkId;
}

class _MonkReviewsProviderElement
    extends AutoDisposeFutureProviderElement<List<MonkReview>>
    with MonkReviewsRef {
  _MonkReviewsProviderElement(super.provider);

  @override
  String get monkId => (origin as MonkReviewsProvider).monkId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
