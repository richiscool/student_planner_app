import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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

  List<Map<String, dynamic>> assignments = [];

  String formatDate(dynamic dateValue) {
    if (dateValue == null) {
      return "Select Due Date";
    }

    DateTime date = DateTime.now();

    if (dateValue is DateTime) {
      date = dateValue;
    } else if (dateValue is String) {
      date = DateTime.parse(dateValue);
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

    setState(() { 
      assignments.add({
        'subject': subjectController.text,
        'homework': homeworkController.text,
        'priority': selectedPriority,
        'dueDate': selectedDueDate?.toIso8601String(),
        'completed': false
      }); 
    });
  
    subjectController.clear();
    homeworkController.clear();
    selectedPriority = "Medium";
    selectedDueDate = null;
    saveAssignments();
  }

  void deleteHomework(int index) {
    setState(() {
      assignments.removeAt(index);
    });
    saveAssignments();
  }

  void togglecompleted(int index) {
    setState(() {
      assignments[index]['completed'] = !assignments[index]['completed'];
    });
    saveAssignments();
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
      return const Color.fromARGB(255, 150, 149, 149);
    }
  }

  Future<void> saveAssignments() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(assignments);
    await prefs.setString('assignments', encodedData);
  }

  Future<void> loadAssignments() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString('assignments');
    
    if (encodedData != null) {
      final List<dynamic> decodedData = jsonDecode(encodedData);

      setState(() {
        assignments = decodedData.map((item) {
          return Map<String, dynamic>.from(item);
        }).toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadAssignments();
  }

  @override
  void dispose() {
    subjectController.dispose();
    homeworkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[350],
      appBar: AppBar(
        title: Text('Student Planner'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
        
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                reverse: true,
                child: Column(
                  children: [
        
                    TextField(controller: subjectController, decoration: InputDecoration(labelText: 'Subject', border: OutlineInputBorder())),
                     SizedBox(height: 10),
        
                    TextField(controller: homeworkController, decoration: InputDecoration(labelText: 'Homework / Assignment', border: OutlineInputBorder())),
                    SizedBox(height: 10),
        
                    DropdownButtonFormField<String>(
                      initialValue: selectedPriority,
                      decoration: InputDecoration(labelText: 'Priority', border: OutlineInputBorder()),
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
                    SizedBox(height: 10),
        
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
                    const SizedBox(height: 10),
        
                    SizedBox(
                      width: double.infinity, 
                      child: ElevatedButton(
                          onPressed: addHomework, 
                          child: Text("Add Homework")
                      )
                    )
                  ]
                )
              ),
        
              const SizedBox(height: 10),
        
              assignments.isEmpty ? 
                const Center(
                  child: Text("No assignments added.", 
                  style: TextStyle(fontSize: 18)
                  )
                ) : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                itemCount: assignments.length,
                itemBuilder: (context, index) {
                  final homework = assignments[index];
                  final overdue = isOverdue(DateTime.parse(homework['dueDate']), homework['completed']);
        
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
              )
            ],
          )
        ),
      ),
    );
  }
}