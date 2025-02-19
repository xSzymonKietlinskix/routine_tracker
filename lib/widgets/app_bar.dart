import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;

  CustomAppBar({Key? key})
      : preferredSize = Size.fromHeight(56.0),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          Icon(Icons.schedule, color: Colors.white, size: 30), // Ikona
          SizedBox(width: 8), // Odstęp między ikoną a tekstem
          Text(
            "Routine Tracker",
            style: TextStyle(
              fontSize: 24, // Zwiększamy rozmiar czcionki
              fontWeight: FontWeight.bold, // Pogrubienie
              letterSpacing: 1.2, // Rozstawienie liter
              fontFamily: 'Roboto', // Czcionka
              color: Colors.white, // Kolor tekstu
            ),
          ),
        ],
      ),
      backgroundColor:
          const Color.fromARGB(185, 131, 31, 162), // Kolor tła AppBar
      elevation: 4, // Cień pod AppBar
    );
  }
}
