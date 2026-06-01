import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../data/habit.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(iOS: iosSettings);
    await _plugin.initialize(settings);
  }

  static Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  static Future<void> scheduleReminder(Habit habit) async {
    if (habit.reminderTime == null) return;

    final parts = habit.reminderTime!.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final location = tz.getLocation('America/Sao_Paulo');
    final now = tz.TZDateTime.now(location);
    var scheduledDate =
        tz.TZDateTime(location, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final notifId = habit.id % 2147483647;

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(iOS: iosDetails);

    await _plugin.zonedSchedule(
      notifId,
      'Broto 🌱',
      'Hora de completar: ${habit.name}',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    await _appendToLog(
      title: 'Broto 🌱',
      body: 'Hora de completar: ${habit.name}',
    );
  }

  static Future<void> cancelReminder(int habitId) async {
    await _plugin.cancel(habitId % 2147483647);
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  static Future<void> scheduleNightSummary() async {
    final location = tz.getLocation('America/Sao_Paulo');
    final now = tz.TZDateTime.now(location);
    var scheduledDate =
        tz.TZDateTime(location, now.year, now.month, now.day, 22, 30);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(iOS: iosDetails);

    await _plugin.zonedSchedule(
      999999999,
      'Broto 🌱',
      'Como foi seu dia? Confira seus hábitos!',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancelNightSummary() async {
    await _plugin.cancel(999999999);
  }

  static Future<void> _appendToLog({
    required String title,
    required String body,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('notification_log') ?? '[]';
    final List<dynamic> list = jsonDecode(raw);
    list.add({
      'title': title,
      'body': body,
      'timestamp': DateTime.now().toIso8601String(),
    });
    await prefs.setString('notification_log', jsonEncode(list));
  }
}
