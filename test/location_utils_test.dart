import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_lost_and_found/core/utils/location_utils.dart';
import 'package:flutter_lost_and_found/core/providers/location_dashboard_provider.dart';

void main() {
  group('LocationUtils Haversine Tests', () {
    test(
      'Calculates distance between Dhaka zero point and nearby point accurately',
      () {
        // Dhaka center: 23.8103, 90.4125
        // Dhanmondi (~3.5km away): 23.7461, 90.3742
        final distKm = LocationUtils.calculateHaversineDistance(
          23.8103,
          90.4125,
          23.7461,
          90.3742,
        );

        expect(distKm, greaterThan(3.0));
        expect(distKm, lessThan(10.0));
      },
    );

    test('Distance to same coordinate is zero', () {
      final distKm = LocationUtils.calculateHaversineDistance(
        23.8103,
        90.4125,
        23.8103,
        90.4125,
      );

      expect(distKm, equals(0.0));
    });

    test('Formats distance under 1 KM as meters', () {
      final formatted = LocationUtils.formatDistance(0.45);
      expect(formatted, equals('450 m'));
    });

    test('Formats distance above 1 KM as KM', () {
      final formatted = LocationUtils.formatDistance(5.23);
      expect(formatted, equals('5.2 KM'));
    });

    test('Formats accuracy string', () {
      final accuracy = LocationUtils.formatAccuracy(8.5);
      expect(accuracy, equals('± 8.5 m'));
    });
  });

  group('RadiusSearchState Tests', () {
    test('Default radius state has 5 KM radius and is enabled', () {
      const state = RadiusSearchState();
      expect(state.radiusKm, equals(5.0));
      expect(state.isEnabled, isTrue);
      expect(state.sortOption, equals('Nearest'));
      expect(state.searchQuery, equals(''));
    });

    test('copyWith creates updated RadiusSearchState', () {
      const state = RadiusSearchState();
      final updated = state.copyWith(
        radiusKm: 20.0,
        sortOption: 'Newest',
        searchQuery: 'iPhone',
      );

      expect(updated.radiusKm, equals(20.0));
      expect(updated.sortOption, equals('Newest'));
      expect(updated.isEnabled, isTrue);
      expect(updated.searchQuery, equals('iPhone'));
    });
  });
}
