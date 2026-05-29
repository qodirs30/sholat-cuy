import 'package:flutter/material.dart';
import '../../domain/entities/user_settings.dart';
import '../../domain/entities/prayer_time.dart';
import '../../domain/usecases/prayer_usecases.dart';
import '../../core/utils/foreground_service_helper.dart';
import '../../core/di/injection.dart';
import '../../data/datasources/notification_service.dart';

class SettingsProvider with ChangeNotifier {
  final GetUserSettings getUserSettingsUseCase;
  final SaveUserSettings saveUserSettingsUseCase;

  UserSettings _settings = UserSettings.defaultSettings();
  bool _isLoading = true;

  SettingsProvider({
    required this.getUserSettingsUseCase,
    required this.saveUserSettingsUseCase,
  });

  UserSettings get settings => _settings;
  bool get isLoading => _isLoading;

  /// Loads stored user settings and configures foreground tasks if needed
  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      _settings = await getUserSettingsUseCase();
      
      // Cancel any remaining spam alarms from past prayer times on app open
      await sl<NotificationService>().cancelActiveSpams();

      // Configure Android Foreground Service based on settings
      if (_settings.spamEnabled) {
        await ForegroundServiceHelper.startService();
      } else {
        await ForegroundServiceHelper.stopService();
      }
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }

  /// Updates settings and saves them to local storage
  Future<void> _updateAndSave(UserSettings newSettings) async {
    _settings = newSettings;
    notifyListeners();
    await saveUserSettingsUseCase(_settings);
  }

  Future<void> updateCalculationMethod(String method) async {
    await _updateAndSave(_settings.copyWith(calculationMethod: method));
  }

  Future<void> updateLocationMode(bool useGps) async {
    await _updateAndSave(_settings.copyWith(useGps: useGps));
  }

  Future<void> updateManualLocation(double lat, double lng, String name) async {
    await _updateAndSave(
      _settings.copyWith(
        manualLatitude: lat,
        manualLongitude: lng,
        manualLocationName: name,
      ),
    );
  }

  Future<void> updateAdzanSound(String sound) async {
    await _updateAndSave(_settings.copyWith(adzanSound: sound));
  }

  Future<void> updateSpamEnabled(bool enabled) async {
    await _updateAndSave(_settings.copyWith(spamEnabled: enabled));
    
    if (enabled) {
      await ForegroundServiceHelper.startService();
    } else {
      await ForegroundServiceHelper.stopService();
    }
  }

  Future<void> updateAlertMinutesBefore(int minutes) async {
    await _updateAndSave(_settings.copyWith(alertMinutesBefore: minutes));
  }

  Future<void> updateTwentyFourHourFormat(bool format) async {
    await _updateAndSave(_settings.copyWith(twentyFourHourFormat: format));
  }

  Future<void> updateLanguage(String langCode) async {
    await _updateAndSave(_settings.copyWith(languageCode: langCode));
  }

  Future<void> toggleNotification(PrayerType type, bool value) async {
    final updatedToggles = Map<PrayerType, bool>.from(_settings.notificationToggles);
    updatedToggles[type] = value;
    await _updateAndSave(_settings.copyWith(notificationToggles: updatedToggles));
  }
}
