import '../entities/prayer_time.dart';
import '../entities/user_settings.dart';

abstract class PrayerRepository {
  /// Fetches the prayer schedule for a specific date and coordinates
  Future<PrayerSchedule> getPrayerSchedule({
    required double latitude,
    required double longitude,
    required DateTime date,
    required UserSettings settings,
  });

  /// Fetches saved user preferences
  Future<UserSettings> getUserSettings();

  /// Saves user preferences locally
  Future<void> saveUserSettings(UserSettings settings);
}
