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

  List<Map<String, dynamic>> homeworks = [];

  String formatDate(DateTime? date) {
    if (date == null) {
      return "Select Due Date";
    }
    return "${date.day}/${date.month}/${date.year}";
  }

  void selectDueDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context, 
      firstDate: DateTime.now(), 
      lastDate: DateTime(2030),
      initialDate: DateTime.now()
    );

    if (pickedDate != null) {
      setState(() {
        selectedDueDate = pickedDate;
      });
    }
  }

  void addHomework() {
    if (subjectController.text.isEmpty || homeworkController.text.isEmpty) {
      return;
    }

    setState(() { homeworks.add({
      'subject': subjectController.text,
      'homeworks': homeworkController.text,
      'priority': selectedPriority,
      'dueDate': selectedDueDate,
      'completed': false
    }); 
  });
  
    subjectController.clear();
    homeworkController.clear();
    selectedPriority = "Medium";
    selectedDueDate = null;
  }

  void deleteHomework(int index) {
    setState(() {
      homeworks.removeAt(index);
    });
  }

  void togglecompleted(int index) {
    setState(() {
      homeworks[index]['completed'] = !homeworks[index]['completed'];
    });
  }

  bool isOverdue(DateTime? date, bool completed) {
    if (date == null || completed) {
      return false;
    }

    final today = DateTime.now();
    
    return date.isBefore(today);
  }

  Color getPriorityColor(String priority) {
    if (priority == "High") {
      return Colors.red;
    } else if (priority == "Medium") {
      return Colors.orange;
    } else {
      return Colors.white;
    }
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

            TextField(controller: homeworkController, decoration: InputDecoration(labelText: 'homeworks')),
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

            Row(
              children: [
                Expanded(child: 
                  Text(formatDate(selectedDueDate), 
                  style: TextStyle(fontSize: 16)
                  )
                ),

                ElevatedButton(
                  onPressed: selectDueDate, 
                  child: Text("Select Due Date")
                ),
            ]
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity, 
              child: 
                ElevatedButton(
                  onPressed: addHomework, 
                  child: Text("Add homeworks")
                )
              ),
            const SizedBox(height: 20),

            Expanded(
              child: homeworks.isEmpty ? 
              const Center(
                child: Text("No homework added.", 
                style: TextStyle(fontSize: 18)
                )
              ) : ListView.builder(
              itemCount: homeworks.length,
              itemBuilder: (context, index) {
                final homework = homeworks[index];
                final overdue = isOverdue(homework['dueDate'], homework['completed']);

                return Card(
                  color: getPriorityColor(homework['priority']),
                  child: ListTile(
                    leading: Checkbox(
                      value: homework['completed'], 
                      onChanged: (value) {togglecompleted(index);}
                    ),
                    title: Text(
                      homework['subject'], 
                      style: TextStyle(
                        decoration: homework['completed'] 
                        ? TextDecoration.lineThrough : TextDecoration.none,
                        fontWeight: FontWeight.bold,
                      )
                    ),
                    subtitle: Text(
                      "${homework['homework']}\n" "Priority: ${homework['priority']}\n" "Due Date: ${formatDate(homework['dueDate'])}", 
                      style: TextStyle(
                        decoration: homework['completed'] 
                        ? TextDecoration.lineThrough : TextDecoration.none,
                        color: overdue ? Colors.red : Colors.black,
                      )
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete), 
                      onPressed: () {deleteHomework(index);}
                    ),
                  ),
                );
              },
            ))
          ],
        )
      ),
    );
  }
}