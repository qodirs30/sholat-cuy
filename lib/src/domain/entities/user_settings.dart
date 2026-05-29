import './prayer_time.dart';

class UserSettings {
  final String calculationMethod; // 'Kemenag', 'ISNA', 'MWL', 'EGYPT'
  final bool useGps;
  final double manualLatitude;
  final double manualLongitude;
  final String manualLocationName;
  final String adzanSound; // 'adzan_1', 'adzan_2', 'beep', 'silent'
  final bool spamEnabled; // Aggressive reminders loop
  final int alertMinutesBefore; // X minutes before adzan (0 for exact time)
  final bool twentyFourHourFormat;
  final String languageCode; // 'id', 'en'
  final Map<PrayerType, bool> notificationToggles;

  UserSettings({
    required this.calculationMethod,
    required this.useGps,
    required this.manualLatitude,
    required this.manualLongitude,
    required this.manualLocationName,
    required this.adzanSound,
    required this.spamEnabled,
    required this.alertMinutesBefore,
    required this.twentyFourHourFormat,
    required this.languageCode,
    required this.notificationToggles,
  });

  factory UserSettings.defaultSettings() {
    return UserSettings(
      calculationMethod: 'Kemenag',
      useGps: true,
      manualLatitude: -6.2088, // Jakarta Default
      manualLongitude: 106.8456,
      manualLocationName: 'Jakarta, Indonesia',
      adzanSound: 'adzan_1',
      spamEnabled: false,
      alertMinutesBefore: 0,
      twentyFourHourFormat: true,
      languageCode: 'id',
      notificationToggles: {
        PrayerType.fajr: true,
        PrayerType.sunrise: false, // Usually no adzan/alarm for sunrise
        PrayerType.dhuhr: true,
        PrayerType.asr: true,
        PrayerType.maghrib: true,
        PrayerType.isha: true,
      },
    );
  }

  UserSettings copyWith({
    String? calculationMethod,
    bool? useGps,
    double? manualLatitude,
    double? manualLongitude,
    String? manualLocationName,
    String? adzanSound,
    bool? spamEnabled,
    int? alertMinutesBefore,
    bool? twentyFourHourFormat,
    String? languageCode,
    Map<PrayerType, bool>? notificationToggles,
  }) {
    return UserSettings(
      calculationMethod: calculationMethod ?? this.calculationMethod,
      useGps: useGps ?? this.useGps,
      manualLatitude: manualLatitude ?? this.manualLatitude,
      manualLongitude: manualLongitude ?? this.manualLongitude,
      manualLocationName: manualLocationName ?? this.manualLocationName,
      adzanSound: adzanSound ?? this.adzanSound,
      spamEnabled: spamEnabled ?? this.spamEnabled,
      alertMinutesBefore: alertMinutesBefore ?? this.alertMinutesBefore,
      twentyFourHourFormat: twentyFourHourFormat ?? this.twentyFourHourFormat,
      languageCode: languageCode ?? this.languageCode,
      notificationToggles: notificationToggles ?? this.notificationToggles,
    );
  }
}
