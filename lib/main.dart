import 'package:flutter/material.dart';
import 'models/task.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'providers/notifications_android.dart';
import 'db/firestore_db.dart';
import 'dart:async';

void scheduleMidnightTask() {
  final FirestoreDb firestoreDb = FirestoreDb();
  DateTime now = DateTime.now();
  DateTime nextMidnight = DateTime(now.year, now.month, now.day + 1, 0, 0, 0);

  Duration initialDelay = nextMidnight.difference(now);

  Future.delayed(initialDelay, () {
    firestoreDb.getTasksToBeDoneForToday(); // Wywołanie funkcji o północy

    Timer.periodic(Duration(days: 1), (timer) {
      firestoreDb.getTasksToBeDoneForToday(); // Każdego dnia o północy
    });
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicjalizacja powiadomień
  await NotificationService.initialize();

  // Nasłuchiwanie na zmiany w Firestore
  NotificationService.listenForTaskUpdates();

  MyApp app = MyApp(
      initialRoute:
          FirebaseAuth.instance.currentUser == null ? "/login" : "/home");
  await app.setupNotifications();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: app,
    ),
  );
  FirestoreDb firestoreDb = FirestoreDb();
  firestoreDb.getTasksToBeDoneForToday();                          
  scheduleMidnightTask();
}

class MyApp extends StatelessWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final String initialRoute;
  MyApp({required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Routine Tracker',
          // theme: ThemeData.light(),
          theme: ThemeData(
            primarySwatch: Colors.purple,
            scaffoldBackgroundColor:
                const Color.fromARGB(255, 247, 243, 248), // Tło aplikacji
            textTheme: TextTheme(
              bodySmall:
                  TextStyle(fontFamily: 'Atkinson Hyperlegible', fontSize: 14),
              bodyMedium:
                  TextStyle(fontFamily: 'Atkinson Hyperlegible', fontSize: 14),
              headlineMedium: TextStyle(
                  fontFamily: 'Atkinson Hyperlegible',
                  fontWeight: FontWeight.bold,
                  fontSize: 32),
              headlineSmall: TextStyle(
                  fontFamily: 'Atkinson Hyperlegible',
                  fontWeight: FontWeight.bold,
                  fontSize: 28),
            ),
          ),
          darkTheme: ThemeData.dark(),
          themeMode: themeProvider.themeMode, // Ustawiamy motyw
          initialRoute: initialRoute, // Ustawiamy initialRoute
          routes: {
            "/login": (context) => LoginScreen(),
            "/home": (context) => HomeScreen(),
          },
        );
      },
    );
  }

  // Funkcja inicjalizująca powiadomienia (teraz już w niestatycznej metodzie)
  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Usuwamy static z tej funkcji i wywołujemy ją na instancji klasy
  Future<void> setupNotifications() async {
    await Permission.notification
        .request(); // Zapytanie o pozwolenie na powiadomienia
    await initializeNotifications(); // Wywołanie metody niestatycznej
  }
}
