import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:adhan/adhan.dart';
import '../../domain/entities/prayer_time.dart';
import '../../domain/entities/user_settings.dart';
import '../../domain/repositories/prayer_repository.dart';
import '../datasources/local_ds.dart';
import '../datasources/location_service.dart';

class PrayerRepositoryImpl implements PrayerRepository {
  final LocalDataSource localDataSource;
  final LocationService locationService;

  PrayerRepositoryImpl({
    required this.localDataSource,
    required this.locationService,
  });

  @override
  Future<PrayerSchedule> getPrayerSchedule({
    required double latitude,
    required double longitude,
    required DateTime date,
    required UserSettings settings,
  }) async {
    // 1. Calculate prayer times offline using adhan library
    final coordinates = Coordinates(latitude, longitude);
    final dateComponents = DateComponents(date.year, date.month, date.day);

    late CalculationParameters params;

    switch (settings.calculationMethod) {
      case 'Kemenag':
        // Kemenag RI standard: Fajr 20 degrees, Isha 18 degrees
        params = CalculationParameters(fajrAngle: 20.0, ishaAngle: 18.0);
        // Kemenag RI applies +2 minutes safety buffer to each prayer time (except sunrise/shuruk)
        params.adjustments.fajr = 2;
        params.adjustments.dhuhr = 2;
        params.adjustments.asr = 2;
        params.adjustments.maghrib = 2;
        params.adjustments.isha = 2;
        break;
      case 'ISNA':
        params = CalculationMethod.north_america.getParameters();
        break;
      case 'MWL':
        params = CalculationMethod.muslim_world_league.getParameters();
        break;
      case 'EGYPT':
        params = CalculationMethod.egyptian.getParameters();
        break;
      default:
        params = CalculationMethod.singapore.getParameters(); // Standard Southeast Asia
        break;
    }

    final adhanTimes = PrayerTimes(coordinates, dateComponents, params);

    // 2. Fetch location name via OpenStreetMap Nominatim reverse geocoding if GPS is active
    String locationName = settings.manualLocationName;
    if (settings.useGps) {
      locationName = await _reverseGeocode(latitude, longitude);
    }

    // 3. Construct entity list
    final List<PrayerTime> prayers = [
      PrayerTime(
        type: PrayerType.fajr,
        name: PrayerType.fajr.displayName,
        time: adhanTimes.fajr.toLocal(),
      ),
      PrayerTime(
        type: PrayerType.sunrise,
        name: PrayerType.sunrise.displayName,
        time: adhanTimes.sunrise.toLocal(),
      ),
      PrayerTime(
        type: PrayerType.dhuhr,
        name: PrayerType.dhuhr.displayName,
        time: adhanTimes.dhuhr.toLocal(),
      ),
      PrayerTime(
        type: PrayerType.asr,
        name: PrayerType.asr.displayName,
        time: adhanTimes.asr.toLocal(),
      ),
      PrayerTime(
        type: PrayerType.maghrib,
        name: PrayerType.maghrib.displayName,
        time: adhanTimes.maghrib.toLocal(),
      ),
      PrayerTime(
        type: PrayerType.isha,
        name: PrayerType.isha.displayName,
        time: adhanTimes.isha.toLocal(),
      ),
    ];

    return PrayerSchedule(
      date: date,
      prayers: prayers,
      locationName: locationName,
    );
  }

  @override
  Future<UserSettings> getUserSettings() {
    return localDataSource.getUserSettings();
  }

  @override
  Future<void> saveUserSettings(UserSettings settings) {
    return localDataSource.saveUserSettings(settings);
  }

  /// Reverse geocode lat/lng into a human-readable city/region name.
  /// Gracefully falls back to GPS coordinate string if offline or error occurs.
  Future<String> _reverseGeocode(double lat, double lng) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=10',
      );
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'SholatCuyApp/1.0 (com.qodir.sholatcuy; contact: qodirs30@example.com)'
        },
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'];
        if (address != null) {
          final city = address['city'] ?? address['town'] ?? address['village'] ?? address['municipality'] ?? address['county'];
          final state = address['state'] ?? address['region'];
          if (city != null && state != null) {
            return '$city, $state';
          } else if (city != null) {
            return '$city';
          } else if (state != null) {
            return '$state';
          }
        }
        return data['display_name'] ?? 'Koordinat: ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
      }
    } catch (_) {
      // Graceful degradation when offline
    }
    return 'Koordinat GPS (${lat.toStringAsFixed(3)}, ${lng.toStringAsFixed(3)})';
  }
}
