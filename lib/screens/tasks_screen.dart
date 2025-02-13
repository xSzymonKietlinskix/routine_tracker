// import 'package:flutter/material.dart';
// import 'package:routine_tracker/db/hive_db.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import '../models/task.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import '../widgets/task_list.dart';
// import 'add_task_screen.dart';

// class TaskListScreen extends StatefulWidget {
//   @override
//   _TaskListScreenState createState() => _TaskListScreenState();
// }

// class _TaskListScreenState extends State<TaskListScreen> {
//   DateTime selectedDate = DateTime.now();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Kalendarz")),
//       body: Column(
//         children: [
//           // **Nagłówek z wyborem dnia**
//           Padding(
//             padding: EdgeInsets.all(8.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 IconButton(
//                   icon: Icon(Icons.arrow_left),
//                   onPressed: () {
//                     setState(() {
//                       selectedDate = selectedDate.subtract(Duration(days: 1));
//                     });
//                   },
//                 ),
//                 Text(
//                     "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}",
//                     style: TextStyle(fontSize: 20)),
//                 IconButton(
//                   icon: Icon(Icons.arrow_right),
//                   onPressed: () {
//                     setState(() {
//                       selectedDate = selectedDate.add(Duration(days: 1));
//                     });
//                   },
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: Container(
//               padding: EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Colors.grey[200],
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: TaskList(selectedDate: selectedDate),
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => addTask()),
//           );
//         },
//         child: Icon(Icons.add),
//         backgroundColor: const Color.fromARGB(255, 135, 16, 141),
//       ),
//     );
//   }
// }
