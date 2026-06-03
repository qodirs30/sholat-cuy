import 'dart:js' as js;

void triggerWebNotificationAndSound(String soundName, String title, String body) {
  try {
    js.context.callMethod('showWebNotification', [title, body]);
    js.context.callMethod('playNotificationSound', [soundName]);
  } catch (e) {
    // Fail silently in release
  }
}
