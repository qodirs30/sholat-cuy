import 'dart:isolate';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

// The callback function that will be executed in the background isolate
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyBackgroundTaskHandler());
}

class MyBackgroundTaskHandler extends TaskHandler {
  int _eventCount = 0;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    // Background task initialization
  }

  @override
  void onRepeatEvent(DateTime timestamp) async {
    _eventCount++;
    // Notify main isolate if active
    FlutterForegroundTask.sendDataToMain(_eventCount);
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    // Clean up background resources
  }
}

class ForegroundServiceHelper {
  /// Initializes the configurations for the Android Foreground Service
  static Future<void> initForegroundTask() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'sholat_cuy_foreground_channel',
        channelName: 'SHOLAT cuy Background Service',
        channelDescription: 'Menjaga keandalan alarm sholat di latar belakang.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(30000), // Every 30 seconds
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  /// Starts the Foreground Service
  static Future<bool> startService() async {
    if (await FlutterForegroundTask.isRunningService) {
      return true;
    }

    // Request permissions (notification, etc. on Android 13+)
    await FlutterForegroundTask.requestNotificationPermission();

    final result = await FlutterForegroundTask.startService(
      notificationTitle: 'SHOLAT cuy aktif',
      notificationText: 'Mengecek waktu shalat dan mengawal alarm adzan.',
      notificationIcon: const NotificationIcon(
        metaDataName: 'mipmap/ic_launcher',
      ),
      callback: startCallback,
    );

    return result is ServiceRequestSuccess;
  }

  /// Stops the Foreground Service
  static Future<bool> stopService() async {
    if (await FlutterForegroundTask.isRunningService) {
      final result = await FlutterForegroundTask.stopService();
      return result is ServiceRequestSuccess;
    }
    return true;
  }
}
