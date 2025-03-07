import 'package:flutter/material.dart';

class TaskRecurringOptions extends StatefulWidget {
  final List<int>? daysOfWeek;
  final Function(List<int>) onDaysSelected;
  final Function(int?) onMonthsSelected;

  TaskRecurringOptions({
    required this.daysOfWeek,
    required this.onDaysSelected,
    required this.onMonthsSelected,
  });

  @override
  _TaskRecurringOptionsState createState() => _TaskRecurringOptionsState();
}

class _TaskRecurringOptionsState extends State<TaskRecurringOptions> {
  List<int> _selectedDays = [];

  @override
  void initState() {
    super.initState();
    _selectedDays = widget.daysOfWeek ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Select Days of the Week", style: TextStyle(fontSize: 16)),
        Wrap(
          spacing: 10,
          children: List.generate(7, (index) {
            return ChoiceChip(
              label: Text(
                  ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][index]),
              selected: _selectedDays.contains(index + 1),
              onSelected: (isSelected) {
                setState(() {
                  if (isSelected) {
                    _selectedDays.add(index + 1);
                  } else {
                    _selectedDays.remove(index + 1);
                  }
                });
                widget.onDaysSelected(_selectedDays);
              },
            );
          }),
        ),
        SizedBox(height: 16),
        Text("Repeat for how many months?", style: TextStyle(fontSize: 16)),
        TextField(
          keyboardType: TextInputType.number,
          onChanged: (value) {
            widget.onMonthsSelected(int.tryParse(value));
          },
          decoration: InputDecoration(
            labelText: "Months",
            hintText: "Enter number of months",
          ),
        ),
      ],
    );
  }
}
