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

Future<void> requestNotificationPermission() async {
  if (await Permission.notification.request().isGranted) {
    print("Powiadomienia są dozwolone");
  } else {
    print("Powiadomienia odrzucone");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  await requestNotificationPermission();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(
        initialRoute:
            FirebaseAuth.instance.currentUser == null ? "/login" : "/home",
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final String initialRoute;
  MyApp({required this.initialRoute});

  void _setupNotifications() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'daily_notification_channel',
      'Codzienne powiadomienia',
      channelDescription: 'Kanał dla codziennych powiadomień',
      importance: Importance.high,
      priority: Priority.high,
      icon: 'ic_notifications', // Ikona powiadomienia
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.initialize(
      InitializationSettings(
          android: AndroidInitializationSettings('ic_notifications')),
    );

    // Tworzenie kanału
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          'daily_notification_channel',
          'Codzienne powiadomienia',
          description: 'Kanał dla codziennych powiadomień',
          importance: Importance.high,
        ));
  }

  @override
  Widget build(BuildContext context) {
    _setupNotifications();
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
}
