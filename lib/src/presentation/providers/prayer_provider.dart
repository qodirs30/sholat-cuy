import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/entities/prayer_time.dart';
import '../../domain/entities/user_settings.dart';
import '../../domain/usecases/prayer_usecases.dart';
import '../../core/di/injection.dart';
import '../../data/datasources/notification_service.dart';
import '../../data/datasources/location_service.dart';

class PrayerProvider with ChangeNotifier {
  final GetPrayerTimes getPrayerTimesUseCase;

  PrayerSchedule? _schedule;
  bool _isLoading = false;
  String _errorMessage = '';

  // Active state
  PrayerTime? _currentPrayer;
  PrayerTime? _nextPrayer;
  Duration _timeToNext = Duration.zero;
  Timer? _countdownTimer;

  PrayerProvider({required this.getPrayerTimesUseCase});

  PrayerSchedule? get schedule => _schedule;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  PrayerTime? get currentPrayer => _currentPrayer;
  PrayerTime? get nextPrayer => _nextPrayer;
  Duration get timeToNext => _timeToNext;

  String get timeToNextString {
    if (_timeToNext == Duration.zero) return '00:00:00';
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(_timeToNext.inHours);
    final minutes = twoDigits(_timeToNext.inMinutes.remainder(60));
    final seconds = twoDigits(_timeToNext.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  /// Returns progress of current prayer time elapsed (from 0.0 to 1.0)
  double get prayerProgress {
    if (_currentPrayer == null || _nextPrayer == null) return 0.0;
    final totalDuration = _nextPrayer!.time.difference(_currentPrayer!.time).inSeconds;
    if (totalDuration <= 0) return 0.0;
    
    final elapsed = DateTime.now().difference(_currentPrayer!.time).inSeconds;
    if (elapsed <= 0) return 0.0;
    if (elapsed >= totalDuration) return 1.0;
    
    return elapsed / totalDuration;
  }

  /// Fetches location coordinates and calculates prayer times
  Future<void> fetchPrayerTimes({required UserSettings settings, DateTime? specificDate}) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final targetDate = specificDate ?? DateTime.now();
    double latitude = settings.manualLatitude;
    double longitude = settings.manualLongitude;

    if (settings.useGps) {
      try {
        final position = await sl<LocationService>().getCurrentLocation();
        latitude = position.latitude;
        longitude = position.longitude;
      } catch (e) {
        // Fallback to manual settings on GPS failure
        _errorMessage = 'Gagal mengambil lokasi GPS. Menggunakan lokasi manual.';
        latitude = settings.manualLatitude;
        longitude = settings.manualLongitude;
      }
    }

    try {
      _schedule = await getPrayerTimesUseCase(
        latitude: latitude,
        longitude: longitude,
        date: targetDate,
        settings: settings,
      );

      _updateActivePrayers();
      _startCountdown();

      // Schedule notification alarms for the new schedule
      if (specificDate == null || specificDate.day == DateTime.now().day) {
        await sl<NotificationService>().schedulePrayerNotifications(
          schedule: _schedule!,
          settings: settings,
        );
      }
    } catch (e) {
      _errorMessage = 'Gagal menghitung jadwal shalat: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  void _updateActivePrayers() {
    if (_schedule == null) return;
    final now = DateTime.now();
    final entry = _schedule!.getCurrentAndNext(now);
    _currentPrayer = entry.key;
    _nextPrayer = entry.value;
    _timeToNext = _nextPrayer!.time.difference(now);
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_nextPrayer == null) return;
      final now = DateTime.now();
      _timeToNext = _nextPrayer!.time.difference(now);

      if (_timeToNext.isNegative || _timeToNext.inSeconds == 0) {
        // Prayer time arrived! Refresh active prayers
        _updateActivePrayers();
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}
