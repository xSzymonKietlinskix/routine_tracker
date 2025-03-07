import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones(); // Inicjalizacja stref czasowych

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> showPersistentNotification(int taskCount) async {
    if (taskCount == 0) {
      await cancelPersistentNotification();
      return;
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'persistent_notification_channel',
      'Trwałe Powiadomienie',
      channelDescription: 'Kanał dla trwałego powiadomienia',
      importance: Importance.high,
      priority: Priority.high,
      ongoing:
          true, // Powiadomienie trwałe (nie może zostać zignorowane przez użytkownika)
      autoCancel: false, // Nie automatycznie znika
      onlyAlertOnce: true, // Powiadomienie pokazuje się tylko raz
      showWhen: false,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      1, // Identyfikator powiadomienia
      'Your tasks',
      taskCount == 1
          ? '1 task to be done today'
          : '$taskCount tasks to be done today',
      notificationDetails,
    );
  }

  static Future<void> cancelPersistentNotification() async {
    await flutterLocalNotificationsPlugin.cancel(1); // Usuwamy powiadomienie
  }

  // Nasłuchiwanie zmian w Firestore i aktualizacja powiadomienia
  static void listenForTaskUpdates() {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print("No user is logged in");
      return;
    }

    String userId = currentUser.uid;
    print("User is logged in with UID: $userId");

    // Subskrypcja na zmiany w dokumencie tasksForToday
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('info')
        .doc('tasksForToday')
        .snapshots()
        .listen((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        // Bezpieczne pobranie wartości 'taskCount' z dokumentu, domyślna wartość to 0
        int taskCount = snapshot.get('count') ?? 0;
        print("Task count updated: $taskCount");
        showPersistentNotification(taskCount); // Zaktualizuj powiadomienie
      } else {
        print("Document does not exist");
      }
    });
  }
}
