import 'package:flutter/material.dart';
import 'student_planner_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Planner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed:Colors.deepPurple),
      home: StudentPlannerPage(),
    );
  }
}
