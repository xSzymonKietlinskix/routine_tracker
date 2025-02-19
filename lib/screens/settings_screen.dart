import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/theme_provider.dart';
import '../auth/auth_service.dart';
import '../providers/notifications_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  TimeOfDay? _morningTime;
  TimeOfDay? _eveningTime;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadNotificationTimes();
  }

  void showTestNotification() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'test_channel',
      'Test Channel',
      icon: 'ic_notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // ID powiadomienia
      'Test Powiadomienie', // Tytuł
      'Działa poprawnie?', // Treść
      platformChannelSpecifics,
    );
  }

  Future<void> _loadNotificationTimes() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    String userId = currentUser.uid;
    try {
      DocumentSnapshot docSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('notifications')
          .get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
        setState(() {
          _morningTime =
              data['morningHour'] != null && data['morningMinute'] != null
                  ? TimeOfDay(
                      hour: data['morningHour'], minute: data['morningMinute'])
                  : null;
          _eveningTime =
              data['eveningHour'] != null && data['eveningMinute'] != null
                  ? TimeOfDay(
                      hour: data['eveningHour'], minute: data['eveningMinute'])
                  : null;
        });
      }
    } catch (e) {
      print("Error loading notification times: $e");
    }
  }

  Future<void> _saveNotificationTime(String type, TimeOfDay time) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    String userId = currentUser.uid;
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('settings')
        .doc('notifications')
        .set({
      if (type == 'morning') ...{
        'morningHour': time.hour,
        'morningMinute': time.minute,
      },
      if (type == 'evening') ...{
        'eveningHour': time.hour,
        'eveningMinute': time.minute,
      }
    }, SetOptions(merge: true));

    scheduleNotification(
        type == 'morning' ? 'Dzień dobry!' : 'Zanim pójdziesz spać...',
        type == 'morning'
            ? 'Sprawdź co dziś na ciebie czeka!'
            : 'Czy zrobiłeś już wszystkie zadania?',
        time.hour,
        time.minute);
  }

  Future<void> _pickTime(BuildContext context, String type) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        if (type == 'morning') {
          _morningTime = pickedTime;
        } else {
          _eveningTime = pickedTime;
        }
      });
      _saveNotificationTime(type, pickedTime);
    }
  }

  Future<void> _signOut(BuildContext context) async {
    await _authService.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    // showTestNotification();
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text("Tryb ciemny"),
              trailing: Switch(
                value: themeProvider.themeMode == ThemeMode.dark,
                onChanged: (value) {
                  themeProvider.toggleTheme(value);
                },
              ),
            ),
            Divider(),
            ListTile(
              title: Text("Poranne powiadomienie"),
              subtitle: Text(_morningTime != null
                  ? "${_morningTime!.hour}:${_morningTime!.minute.toString().padLeft(2, '0')}"
                  : "Nie ustawiono"),
              leading: Icon(Icons.wb_sunny),
              onTap: () => _pickTime(context, 'morning'),
            ),
            ListTile(
              title: Text("Wieczorne powiadomienie"),
              subtitle: Text(_eveningTime != null
                  ? "${_eveningTime!.hour}:${_eveningTime!.minute.toString().padLeft(2, '0')}"
                  : "Nie ustawiono"),
              leading: Icon(Icons.nightlight_round),
              onTap: () => _pickTime(context, 'evening'),
            ),
            Divider(),
            ListTile(
              title: Text("Wyloguj się", style: TextStyle(color: Colors.red)),
              leading: Icon(Icons.exit_to_app, color: Colors.red),
              onTap: () => _signOut(context),
            ),
          ],
        ),
      ),
    );
  }
}
