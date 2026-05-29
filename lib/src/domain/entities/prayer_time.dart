import 'package:flutter/foundation.dart';

enum PrayerType {
  fajr,
  sunrise,
  dhuhr,
  asr,
  maghrib,
  isha,
}

extension PrayerTypeExtension on PrayerType {
  String get displayName {
    switch (this) {
      case PrayerType.fajr:
        return 'Subuh';
      case PrayerType.sunrise:
        return 'Terbit';
      case PrayerType.dhuhr:
        return 'Zuhur';
      case PrayerType.asr:
        return 'Asar';
      case PrayerType.maghrib:
        return 'Maghrib';
      case PrayerType.isha:
        return 'Isya';
    }
  }
}

@immutable
class PrayerTime {
  final PrayerType type;
  final String name;
  final DateTime time;

  const PrayerTime({
    required this.type,
    required this.name,
    required this.time,
  });
}

@immutable
class PrayerSchedule {
  final DateTime date;
  final List<PrayerTime> prayers;
  final String locationName;

  const PrayerSchedule({
    required this.date,
    required this.prayers,
    required this.locationName,
  });

  PrayerTime get fajr => prayers.firstWhere((p) => p.type == PrayerType.fajr);
  PrayerTime get sunrise => prayers.firstWhere((p) => p.type == PrayerType.sunrise);
  PrayerTime get dhuhr => prayers.firstWhere((p) => p.type == PrayerType.dhuhr);
  PrayerTime get asr => prayers.firstWhere((p) => p.type == PrayerType.asr);
  PrayerTime get maghrib => prayers.firstWhere((p) => p.type == PrayerType.maghrib);
  PrayerTime get isha => prayers.firstWhere((p) => p.type == PrayerType.isha);

  /// Returns the current active prayer and the next prayer.
  MapEntry<PrayerTime, PrayerTime> getCurrentAndNext(DateTime now) {
    // Sort prayers just in case
    final sorted = List<PrayerTime>.from(prayers)..sort((a, b) => a.time.compareTo(b.time));
    
    // If it's before Subuh of today
    if (now.isBefore(sorted.first.time)) {
      // Current is Isha of yesterday, next is Subuh of today
      final yesterdayIsha = DateTime(date.year, date.month, date.day - 1, isha.time.hour, isha.time.minute);
      return MapEntry(
        PrayerTime(type: PrayerType.isha, name: 'Isya (Kemarin)', time: yesterdayIsha),
        sorted.first,
      );
    }
    
    // Find next prayer
    for (int i = 0; i < sorted.length; i++) {
      if (now.isBefore(sorted[i].time)) {
        return MapEntry(sorted[i - 1], sorted[i]);
      }
    }
    
    // If it's after Isha of today, next is Subuh of tomorrow
    final tomorrowSubuh = DateTime(date.year, date.month, date.day + 1, fajr.time.hour, fajr.time.minute);
    return MapEntry(
      sorted.last,
      PrayerTime(type: PrayerType.fajr, name: 'Subuh (Besok)', time: tomorrowSubuh),
    );
  }
}
