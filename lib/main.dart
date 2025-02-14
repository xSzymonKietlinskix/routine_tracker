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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // await Hive.initFlutter();
  // Hive.registerAdapter(TaskAdapter());
  // // await Hive.deleteBoxFromDisk('tasks');

  // await Hive.openBox<Task>('tasks'); // Open db

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
  final String initialRoute;
  MyApp({required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Routine Tracker',
          theme: ThemeData.light(),
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
