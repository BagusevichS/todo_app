import 'package:flutter/material.dart';
import 'package:todo_app/screens/home.dart';

void main() {
  runApp(const ToDoApp());
}

class ToDoApp extends StatelessWidget {

  const ToDoApp({Key? key}) : super(key: key);

  @override
 Widget build(BuildContext context) {
  return MaterialApp(
    theme: ThemeData(useMaterial3: false),
    title: 'ToDo App',
    home: const Home(),
  );
  }
}

