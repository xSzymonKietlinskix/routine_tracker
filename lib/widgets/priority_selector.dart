import 'package:flutter/material.dart';

class PrioritySelector extends StatelessWidget {
  final int? selectedPriority;
  final Function(int) onPrioritySelected;

  PrioritySelector({this.selectedPriority, required this.onPrioritySelected});

  final List<int> _priorities = [1, 2, 3];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          right: 35.0, left: 15.0), // Dodajemy odległość od dołu ekranu
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.start, // Domyślne wyrównanie do lewej dla tekstu
        children: [
          // Tekst po lewej stronie
          Text("Priority", style: TextStyle(fontSize: 16)),
          // Rozciągający się element, który wpycha DropdownButton na prawo
          Spacer(),
          // DropdownButton po prawej stronie
          DropdownButton<int>(
            value: selectedPriority,
            items: _priorities
                .map((priority) =>
                    DropdownMenuItem(value: priority, child: Text("$priority")))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                onPrioritySelected(value);
              }
            },
          ),
        ],
      ),
    );
  }
}
