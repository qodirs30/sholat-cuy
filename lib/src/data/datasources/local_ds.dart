import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user_settings.dart';
import '../../domain/entities/prayer_time.dart';

abstract class LocalDataSource {
  Future<UserSettings> getUserSettings();
  Future<void> saveUserSettings(UserSettings settings);
}

class LocalDataSourceImpl implements LocalDataSource {
  final SharedPreferences sharedPreferences;

  LocalDataSourceImpl({required this.sharedPreferences});

  // Keys
  static const String keyCalculationMethod = 'calculation_method';
  static const String keyUseGps = 'use_gps';
  static const String keyManualLat = 'manual_lat';
  static const String keyManualLng = 'manual_lng';
  static const String keyManualLocationName = 'manual_location_name';
  static const String keyAdzanSound = 'adzan_sound';
  static const String keySpamEnabled = 'spam_enabled';
  static const String keyAlertMinutesBefore = 'alert_minutes_before';
  static const String keyTwentyFourHourFormat = 'twenty_four_hour_format';
  static const String keyLanguageCode = 'language_code';

  static const String keyToggleFajr = 'toggle_fajr';
  static const String keyToggleSunrise = 'toggle_sunrise';
  static const String keyToggleDhuhr = 'toggle_dhuhr';
  static const String keyToggleAsr = 'toggle_asr';
  static const String keyToggleMaghrib = 'toggle_maghrib';
  static const String keyToggleIsha = 'toggle_isha';

  @override
  Future<UserSettings> getUserSettings() async {
    final method = sharedPreferences.getString(keyCalculationMethod) ?? 'Kemenag';
    final useGps = sharedPreferences.getBool(keyUseGps) ?? true;
    final lat = sharedPreferences.getDouble(keyManualLat) ?? -6.2088; // Jakarta
    final lng = sharedPreferences.getDouble(keyManualLng) ?? 106.8456;
    final locName = sharedPreferences.getString(keyManualLocationName) ?? 'Jakarta, Indonesia';
    final sound = sharedPreferences.getString(keyAdzanSound) ?? 'adzan_1';
    final spam = sharedPreferences.getBool(keySpamEnabled) ?? false;
    final minutes = sharedPreferences.getInt(keyAlertMinutesBefore) ?? 0;
    final tfFormat = sharedPreferences.getBool(keyTwentyFourHourFormat) ?? true;
    final lang = sharedPreferences.getString(keyLanguageCode) ?? 'id';

    final toggles = {
      PrayerType.fajr: sharedPreferences.getBool(keyToggleFajr) ?? true,
      PrayerType.sunrise: sharedPreferences.getBool(keyToggleSunrise) ?? false,
      PrayerType.dhuhr: sharedPreferences.getBool(keyToggleDhuhr) ?? true,
      PrayerType.asr: sharedPreferences.getBool(keyToggleAsr) ?? true,
      PrayerType.maghrib: sharedPreferences.getBool(keyToggleMaghrib) ?? true,
      PrayerType.isha: sharedPreferences.getBool(keyToggleIsha) ?? true,
    };

    return UserSettings(
      calculationMethod: method,
      useGps: useGps,
      manualLatitude: lat,
      manualLongitude: lng,
      manualLocationName: locName,
      adzanSound: sound,
      spamEnabled: spam,
      alertMinutesBefore: minutes,
      twentyFourHourFormat: tfFormat,
      languageCode: lang,
      notificationToggles: toggles,
    );
  }

  @override
  Future<void> saveUserSettings(UserSettings settings) async {
    await sharedPreferences.setString(keyCalculationMethod, settings.calculationMethod);
    await sharedPreferences.setBool(keyUseGps, settings.useGps);
    await sharedPreferences.setDouble(keyManualLat, settings.manualLatitude);
    await sharedPreferences.setDouble(keyManualLng, settings.manualLongitude);
    await sharedPreferences.setString(keyManualLocationName, settings.manualLocationName);
    await sharedPreferences.setString(keyAdzanSound, settings.adzanSound);
    await sharedPreferences.setBool(keySpamEnabled, settings.spamEnabled);
    await sharedPreferences.setInt(keyAlertMinutesBefore, settings.alertMinutesBefore);
    await sharedPreferences.setBool(keyTwentyFourHourFormat, settings.twentyFourHourFormat);
    await sharedPreferences.setString(keyLanguageCode, settings.languageCode);

    await sharedPreferences.setBool(keyToggleFajr, settings.notificationToggles[PrayerType.fajr] ?? true);
    await sharedPreferences.setBool(keyToggleSunrise, settings.notificationToggles[PrayerType.sunrise] ?? false);
    await sharedPreferences.setBool(keyToggleDhuhr, settings.notificationToggles[PrayerType.dhuhr] ?? true);
    await sharedPreferences.setBool(keyToggleAsr, settings.notificationToggles[PrayerType.asr] ?? true);
    await sharedPreferences.setBool(keyToggleMaghrib, settings.notificationToggles[PrayerType.maghrib] ?? true);
    await sharedPreferences.setBool(keyToggleIsha, settings.notificationToggles[PrayerType.isha] ?? true);
  }
}
