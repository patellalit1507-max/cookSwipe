import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Meal reminders:
///   * 11:00 — "What should we cook for lunch today?"
///   * 18:00 — "What should we cook for dinner tonight?"
///
/// Implemented as daily local notifications (reliable, no server needed).
/// FCM is also wired up (topic `meal_reminders`) so campaigns can be sent
/// from the Firebase console. Users can disable reminders in Settings.
class NotificationService {
  static const _channel = AndroidNotificationDetails(
    'cookswipe_reminders',
    'Meal reminders',
    channelDescription: 'Daily reminders to decide your next meal',
    importance: Importance.defaultImportance,
  );

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init({required bool firebaseEnabled}) async {
    try {
      tzdata.initializeTimeZones();
      try {
        final localName = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(localName));
      } catch (_) {
        // Fall back to the package default if the zone can't be resolved.
      }

      await _plugin.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
      );

      if (firebaseEnabled) {
        try {
          await FirebaseMessaging.instance.requestPermission();
          await FirebaseMessaging.instance.subscribeToTopic('meal_reminders');
        } catch (e) {
          debugPrint('FCM setup failed: $e');
        }
      }
    } catch (e) {
      debugPrint('NotificationService init failed: $e');
    }
  }

  /// Android 13+ runtime permission. Returns whether notifications
  /// are permitted.
  Future<bool> requestPermission() async {
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      return await android?.requestNotificationsPermission() ?? true;
    } catch (_) {
      return false;
    }
  }

  Future<void> scheduleDailyReminders() async {
    try {
      await _plugin.zonedSchedule(
        1,
        'CookSwipe',
        'What should we cook for lunch today?',
        _nextInstanceOf(11, 0),
        const NotificationDetails(android: _channel),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      await _plugin.zonedSchedule(
        2,
        'CookSwipe',
        'What should we cook for dinner tonight?',
        _nextInstanceOf(18, 0),
        const NotificationDetails(android: _channel),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Scheduling reminders failed: $e');
    }
  }

  Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
      await FirebaseMessaging.instance.unsubscribeFromTopic('meal_reminders');
    } catch (_) {}
  }

  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
