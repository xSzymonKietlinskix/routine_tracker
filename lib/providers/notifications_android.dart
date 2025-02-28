import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> checkAndRequestExactAlarms() async {
    if (Platform.isAndroid) {
      var status = await Permission.scheduleExactAlarm.status;
      if (!status.isGranted) {
        print("Brak pozwolenia na dokładne alarmy! Otwieranie ustawień...");
        await openExactAlarmSettings();
      }
    }
  }

  static Future<void> openExactAlarmSettings() async {
    final intent = AndroidIntent(
      action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
      flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
    );
    await intent.launch();
  }

  static Future<void> initialize() async {
    tz.initializeTimeZones(); // Inicjalizacja stref czasowych

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> scheduleDailyNotification(
      int hour, int minute, String title, String text) async {
    await checkAndRequestExactAlarms();
    tz.TZDateTime scheduledTime = _nextInstanceOfTime(hour, minute);
    print("Powiadomienie zaplanowane na: $scheduledTime");

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      title,
      text,
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_notification_channel',
          'Codzienne Powiadomienia',
          channelDescription: 'Kanał dla codziennych powiadomień',
          importance: Importance.max,
          priority: Priority.high,
          // sound: RawResourceAndroidNotificationSound('notification_sound'),
          sound: null,
          // icon:
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduleTime =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduleTime.isBefore(now)) {
      scheduleTime = scheduleTime.add(const Duration(days: 1));
    }
    return scheduleTime;
  }

  static Future<void> showPersistentNotification(int taskCount) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'persistent_notification_channel',
      'Trwałe Powiadomienie',
      channelDescription: 'Kanał dla trwałego powiadomienia',
      importance: Importance.high,
      priority: Priority.high,
      ongoing: true, // Powiadomienie nie może zostać usunięte ręcznie
      autoCancel: false, // Nie zamyka się po kliknięciu
      onlyAlertOnce: true, // Nie powiadamia dźwiękiem przy każdej aktualizacji
      showWhen: false, // Ukrywa czas wysłania powiadomienia
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      1, // ID powiadomienia, aby aktualizować zamiast tworzyć nowe
      'Twoje zadania',
      'Pozostało $taskCount zadań do wykonania',
      notificationDetails,
    );
  }

// Metoda do usunięcia powiadomienia (jeśli wszystkie zadania są wykonane)
  static Future<void> cancelPersistentNotification() async {
    await flutterLocalNotificationsPlugin.cancel(1);
  }
}
