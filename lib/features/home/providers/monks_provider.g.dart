// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monks_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recommendedMonksHash() => r'10953f6c6998c9ec0026e7dc97047bfefe6a050b';

/// See also [recommendedMonks].
@ProviderFor(recommendedMonks)
final recommendedMonksProvider = AutoDisposeFutureProvider<List<Monk>>.internal(
  recommendedMonks,
  name: r'recommendedMonksProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recommendedMonksHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef RecommendedMonksRef = AutoDisposeFutureProviderRef<List<Monk>>;
String _$monksNotifierHash() => r'e4c6991e3c333737ad2cc3cf744f0e37d34d8e91';

/// See also [MonksNotifier].
@ProviderFor(MonksNotifier)
final monksNotifierProvider =
    AutoDisposeAsyncNotifierProvider<MonksNotifier, List<Monk>>.internal(
  MonksNotifier.new,
  name: r'monksNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$monksNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MonksNotifier = AutoDisposeAsyncNotifier<List<Monk>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
