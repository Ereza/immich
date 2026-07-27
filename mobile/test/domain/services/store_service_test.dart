import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:immich_mobile/domain/models/store.model.dart';
import 'package:immich_mobile/domain/services/store.service.dart';
import 'package:immich_mobile/infrastructure/repositories/store.repository.dart';
import 'package:mocktail/mocktail.dart';

import '../../infrastructure/repository.mock.dart';

const _kAccessToken = '#ThisIsAToken';
const _kAdvancedTroubleshooting = false;
const _kVersion = 2;

void main() {
  late StoreService sut;
  late DriftStoreRepository mockDriftStoreRepo;
  late StreamController<List<StoreDto<Object>>> controller;

  setUp(() async {
    controller = StreamController<List<StoreDto<Object>>>.broadcast();
    mockDriftStoreRepo = MockDriftStoreRepository();
    // For generics, we need to provide fallback to each concrete type to avoid runtime errors
    registerFallbackValue(StoreKey.accessToken);
    registerFallbackValue(StoreKey.version);
    registerFallbackValue(StoreKey.advancedTroubleshooting);

    when(() => mockDriftStoreRepo.getAll()).thenAnswer(
      (_) async => [
        const StoreDto(.accessToken, _kAccessToken),
        const StoreDto(.advancedTroubleshooting, _kAdvancedTroubleshooting),
        const StoreDto(.version, _kVersion),
      ],
    );
    when(() => mockDriftStoreRepo.watchAll()).thenAnswer((_) => controller.stream);

    sut = await StoreService.create(storeRepository: mockDriftStoreRepo);
  });

  tearDown(() async {
    unawaited(sut.dispose());
    await controller.close();
  });

  group("Store Service Init:", () {
    test('Populates the internal cache on init', () {
      verify(() => mockDriftStoreRepo.getAll()).called(1);
      expect(sut.tryGet(.accessToken), _kAccessToken);
      expect(sut.tryGet(.advancedTroubleshooting), _kAdvancedTroubleshooting);
      expect(sut.tryGet(.version), _kVersion);
      // Other keys should be null
      expect(sut.tryGet(.currentUser), isNull);
    });

    test('Listens to stream of store updates', () async {
      final event = StoreDto(.accessToken, _kAccessToken.toUpperCase());
      controller.add([event]);

      await pumpEventQueue();

      verify(() => mockDriftStoreRepo.watchAll()).called(1);
      expect(sut.tryGet(.accessToken), _kAccessToken.toUpperCase());
    });
  });

  group('Store Service get:', () {
    test('Returns the stored value for the given key', () {
      expect(sut.get(.accessToken), _kAccessToken);
    });

    test('Throws StoreKeyNotFoundException for nonexistent keys', () {
      expect(() => sut.get(.currentUser), throwsA(isA<StoreKeyNotFoundException>()));
    });

    test('Returns the stored value for the given key or the defaultValue', () {
      expect(sut.get(.currentUser, 5), 5);
    });
  });

  group('Store Service put:', () {
    setUp(() {
      when(() => mockDriftStoreRepo.upsert<String>(any<StoreKey<String>>(), any())).thenAnswer((_) async => true);
    });

    test('Skip insert when value is not modified', () async {
      await sut.put(StoreKey.accessToken, _kAccessToken);
      verifyNever(() => mockDriftStoreRepo.upsert<String>(.accessToken, any()));
    });

    test('Insert value when modified', () async {
      final newAccessToken = _kAccessToken.toUpperCase();
      await sut.put(StoreKey.accessToken, newAccessToken);
      verify(() => mockDriftStoreRepo.upsert<String>(.accessToken, newAccessToken)).called(1);
      expect(sut.tryGet(.accessToken), newAccessToken);
    });
  });

  group('Store Service watch:', () {
    late StreamController<String?> valueController;

    setUp(() {
      valueController = StreamController<String?>.broadcast();
      when(() => mockDriftStoreRepo.watch<String>(any<StoreKey<String>>())).thenAnswer((_) => valueController.stream);
    });

    tearDown(() async {
      await valueController.close();
    });

    test('Watches a specific key for changes', () async {
      final stream = sut.watch(.accessToken);
      final events = <String?>[_kAccessToken, _kAccessToken.toUpperCase(), null, _kAccessToken.toLowerCase()];

      unawaited(expectLater(stream, emitsInOrder(events)));

      for (final event in events) {
        valueController.add(event);
      }

      await pumpEventQueue();
      verify(() => mockDriftStoreRepo.watch<String>(.accessToken)).called(1);
    });
  });

  group('Store Service delete:', () {
    setUp(() {
      when(() => mockDriftStoreRepo.delete<String>(any<StoreKey<String>>())).thenAnswer((_) async => true);
    });

    test('Removes the value from the DB', () async {
      await sut.delete(.accessToken);
      verify(() => mockDriftStoreRepo.delete<String>(.accessToken)).called(1);
    });

    test('Removes the value from the cache', () async {
      await sut.delete(.accessToken);
      expect(sut.tryGet(.accessToken), isNull);
    });
  });

  group('Store Service clear:', () {
    setUp(() {
      when(() => mockDriftStoreRepo.deleteAll()).thenAnswer((_) async => true);
    });

    test('Clears all values from the store', () async {
      await sut.clear();
      verify(() => mockDriftStoreRepo.deleteAll()).called(1);
      expect(sut.tryGet(.accessToken), isNull);
      expect(sut.tryGet(.advancedTroubleshooting), isNull);
      expect(sut.tryGet(.version), isNull);
    });
  });
}
