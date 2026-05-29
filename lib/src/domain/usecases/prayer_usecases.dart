import '../entities/prayer_time.dart';
import '../entities/user_settings.dart';
import '../entities/islamic_event.dart';
import '../repositories/prayer_repository.dart';

class GetPrayerTimes {
  final PrayerRepository repository;

  GetPrayerTimes(this.repository);

  Future<PrayerSchedule> call({
    required double latitude,
    required double longitude,
    required DateTime date,
    required UserSettings settings,
  }) {
    return repository.getPrayerSchedule(
      latitude: latitude,
      longitude: longitude,
      date: date,
      settings: settings,
    );
  }
}

class SaveUserSettings {
  final PrayerRepository repository;

  SaveUserSettings(this.repository);

  Future<void> call(UserSettings settings) {
    return repository.saveUserSettings(settings);
  }
}

class GetUserSettings {
  final PrayerRepository repository;

  GetUserSettings(this.repository);

  Future<UserSettings> call() {
    return repository.getUserSettings();
  }
}

class GetIslamicEvents {
  List<IslamicEvent> call() {
    return IslamicEvent.staticEvents;
  }
}
