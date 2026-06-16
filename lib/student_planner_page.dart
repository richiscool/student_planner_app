import 'package:flutter/material.dart';

class StudentPlannerPage extends StatefulWidget {
  const StudentPlannerPage({super.key});

  @override
  State<StudentPlannerPage> createState() => _StudentPlannerPageState();
}

class _StudentPlannerPageState extends State<StudentPlannerPage> {

  final TextEditingController subjectController = TextEditingController();
  final TextEditingController homeworkController = TextEditingController();

  String selectedPriority = "Medium";
  DateTime? selectedDueDate;

  List<Map<String, dynamic>> homework = [];

  String formatDate(DateTime? date) {
    if (date == null) {
      return "Select Due Date";
    };

    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[350],
      appBar: AppBar(
        title: Text('Student Planner'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(controller: subjectController, decoration: InputDecoration(labelText: 'Subject')),
            SizedBox(height: 16),

            TextField(controller: homeworkController, decoration: InputDecoration(labelText: 'Homework')),
            SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: selectedPriority,

              items: const [
                DropdownMenuItem(value: "Low", child: Text("Low")),
                DropdownMenuItem(value: "Medium", child: Text("Medium")),
                DropdownMenuItem(value: "High", child: Text("High"))
              ],

              onChanged: (value) {
                setState(() {
                  selectedPriority = value ?? "Medium";
                });
              },
            ),
            SizedBox(height: 16),

            Row(children: [
              Expanded(child: 
                Text(formatDate(selectedDueDate), style: TextStyle(fontSize: 16)
                )
              )
            ]
            )
          ],
        )
      ),
    );
  }
}