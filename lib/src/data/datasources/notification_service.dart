import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../core/utils/web_helper.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../domain/entities/prayer_time.dart';
import '../../domain/entities/user_settings.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initializes the notification system, requests permissions, and configures channels.
  Future<void> init() async {
    if (kIsWeb) return;
    // Initialize timezone database
    tz.initializeTimeZones();

    // Android Settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS Settings (requests Critical Alerts as well)
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      requestCriticalPermission: true, // For Critical Alerts on iOS
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Cancel all active spam notifications when a user taps on any notification
        await cancelActiveSpams();
      },
    );
  }

  /// Cancels all active and scheduled notifications.
  Future<void> cancelAll() async {
    if (kIsWeb) return;
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Cancels only the active/future spam notifications (e.g. when app is opened).
  Future<void> cancelActiveSpams() async {
    if (kIsWeb) return;
    // Standard prayer IDs are 0 to 5. Spam IDs are 100 to 130.
    for (int id = 100; id <= 130; id++) {
      await flutterLocalNotificationsPlugin.cancel(id);
    }
  }

  /// Schedules daily notifications for the 5 main prayers.
  /// If spam mode is enabled in [settings], it will also schedule 4 additional
  /// follow-up alarms spaced 2 minutes apart for each enabled prayer.
  Future<void> schedulePrayerNotifications({
    required PrayerSchedule schedule,
    required UserSettings settings,
  }) async {
    if (kIsWeb) return;
    // First, clear previous notifications to avoid duplicate triggers
    await cancelAll();

    final now = DateTime.now();

    for (var prayer in schedule.prayers) {
      // Skip Sunrise/Terbit for adzan notifications
      if (prayer.type == PrayerType.sunrise) continue;

      // Check if notifications are enabled for this specific prayer
      final isEnabled = settings.notificationToggles[prayer.type] ?? true;
      if (!isEnabled) continue;

      // Ensure the scheduled time is in the future
      DateTime scheduleTime = prayer.time.subtract(Duration(minutes: settings.alertMinutesBefore));
      if (scheduleTime.isBefore(now)) {
        // If it already passed today, schedule for tomorrow
        scheduleTime = scheduleTime.add(const Duration(days: 1));
      }

      final prayerId = prayer.type.index; // 0 for fajr, 2 for dhuhr, etc.
      final soundFile = _getSoundFileName(settings.adzanSound);

      // 1. Schedule the main notification (adzan)
      await _scheduleNotification(
        id: prayerId,
        title: 'Waktu ${prayer.name} telah tiba!',
        body: 'Mari bersiap untuk menunaikan ibadah shalat ${prayer.name} di ${schedule.locationName}.',
        scheduledDateTime: scheduleTime,
        soundName: soundFile,
      );

      // 2. Schedule Spam reminders if enabled (bombardment sequence)
      if (settings.spamEnabled) {
        // Schedule 5 notifications spaced 2 minutes apart (starting 2 minutes after the main time)
        for (int i = 1; i <= 5; i++) {
          final spamId = 100 + (prayerId * 5) + i; // Unique range: 100 to 130
          final spamTime = scheduleTime.add(Duration(minutes: i * 2));

          await _scheduleNotification(
            id: spamId,
            title: 'Panggilan Shalat ${prayer.name} (Penting!)',
            body: 'Pengingat Ke-${i}: Waktu shalat ${prayer.name} sedang berlangsung. Ayo shalat!',
            scheduledDateTime: spamTime,
            soundName: soundFile,
            isCritical: true, // Mark as critical alert for iOS/Android overrides
          );
        }
      }
    }
  }

  /// Helper to schedule a single notification at a specific time.
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
    required String soundName,
    bool isCritical = false,
  }) async {
    if (kIsWeb) return;
    final tzTime = tz.TZDateTime.from(scheduledDateTime, tz.local);

    // Android configuration
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'sholat_cuy_prayer_channel',
      'Jadwal Shalat Channel',
      channelDescription: 'Saluran untuk pengingat waktu shalat dan alarm Adzan.',
      importance: Importance.max,
      priority: Priority.high,
      playSound: soundName != 'silent',
      sound: soundName != 'silent'
          ? RawResourceAndroidNotificationSound(soundName)
          : null,
      fullScreenIntent: isCritical,
      ongoing: isCritical, // Makes the notification persistent in Android notification drawer
      styleInformation: const BigTextStyleInformation(''),
    );

    // iOS configuration
    final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: soundName != 'silent' ? '$soundName.mp3' : null,
      // Critical alerts config (can play sound even in silent mode)
      presentBanner: true,
      presentList: true,
      interruptionLevel: isCritical ? InterruptionLevel.critical : InterruptionLevel.active,
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzTime,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // Repeats daily at this time
    );
  }

  /// Map settings selection to local sound resource name.
  String _getSoundFileName(String settingSound) {
    switch (settingSound) {
      case 'adzan_1':
        return 'adzan_mekkah';
      case 'adzan_2':
        return 'adzan_madinah';
      case 'beep':
        return 'beep';
      case 'silent':
      default:
        return 'silent';
    }
  }

  /// Plays sound and shows notification on Web using JS interop.
  Future<void> triggerWebAlarm({
    required String soundName,
    required String title,
    required String body,
  }) async {
    if (!kIsWeb) return;
    triggerWebNotificationAndSound(soundName, title, body);
  }
}
