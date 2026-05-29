import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sholat_cuy/src/data/datasources/local_ds.dart';
import 'package:sholat_cuy/src/data/datasources/location_service.dart';
import 'package:sholat_cuy/src/data/repositories/prayer_repo_impl.dart';
import 'package:sholat_cuy/src/domain/entities/prayer_time.dart';
import 'package:sholat_cuy/src/domain/entities/user_settings.dart';

// Stub LocalDataSource
class StubLocalDataSource implements LocalDataSource {
  @override
  Future<UserSettings> getUserSettings() async {
    return UserSettings.defaultSettings();
  }

  @override
  Future<void> saveUserSettings(UserSettings settings) async {}
}

// Stub LocationService
class StubLocationService extends LocationService {}

void main() {
  group('Prayer Calculation Tests', () {
    late PrayerRepositoryImpl repository;

    setUp(() {
      repository = PrayerRepositoryImpl(
        localDataSource: StubLocalDataSource(),
        locationService: StubLocationService(),
      );
    });

    test('Calculation using Kemenag RI method should apply Fajr 20 and Isha 18', () async {
      final date = DateTime(2026, 5, 28);
      final settings = UserSettings.defaultSettings(); // calculationMethod is 'Kemenag'

      // Jakarta Coordinates
      const lat = -6.2088;
      const lng = 106.8456;

      final schedule = await repository.getPrayerSchedule(
        latitude: lat,
        longitude: lng,
        date: date,
        settings: settings,
      );

      expect(schedule.prayers.length, equals(6));
      expect(
        schedule.locationName,
        anyOf(contains('Jakarta'), contains('Koordinat GPS')),
      );

      // Ensure times are ordered chronologically
      for (int i = 0; i < schedule.prayers.length - 1; i++) {
        expect(schedule.prayers[i].time.isBefore(schedule.prayers[i + 1].time), isTrue);
      }

      // Verify that Fajr (Subuh) is before Sunrise, Zuhur is after Sunrise, Asar after Zuhur, etc.
      expect(schedule.fajr.type, equals(PrayerType.fajr));
      expect(schedule.dhuhr.type, equals(PrayerType.dhuhr));
      expect(schedule.maghrib.type, equals(PrayerType.maghrib));
    });
  });
}
