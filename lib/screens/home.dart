import 'dart:convert';
import 'package:flutter/material.dart';
import '../Constants/mycolors.dart';
import '../Widgets/todo_item.dart';
import '../model/todo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var todosList = <ToDo>[];
  final _todoController = TextEditingController();
  List<ToDo> _foundToDo = [];
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _loadToDoList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Мои задачи',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: tdBlack,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: tdGrey,
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Column(
                children: [
                  searchBox(),
                  Expanded(
                    child: ListView(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 50, bottom: 20),
                          child: const Text(
                            'Все задачи',
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.w500),
                          ),
                        ),
                        for (ToDo todo in _foundToDo.reversed)
                          ToDoItem(
                            todo: todo,
                            onToDoChanged: _handleToDoChange,
                            onDeleteItem: _toDoDeleteItem,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20, right: 20, left: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    decoration: BoxDecoration(
                        color: tdWhite,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            offset: Offset(0.0, 0.0),
                            blurRadius: 10.0,
                            spreadRadius: 0.0,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: TextField(
                      controller: _todoController,
                      decoration: const InputDecoration(
                          hintText: 'Добавь новую заметку',
                          border: InputBorder.none),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 20, right: 20),
                  child: ElevatedButton(onPressed: () {
                    if(_todoController.text.isNotEmpty) {
                      _addToDoItem(_todoController.text);
                    }
                  },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: tdBlue,
                        minimumSize: const Size(60, 60),
                        elevation: 10
                    ),
                    child: const Text('+',style: TextStyle(fontSize: 40),),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleToDoChange(ToDo todo) async {
    setState(() {
      todo.isDone = !todo.isDone;
      _runFilter(_todoController.text);//update
    });
    await _saveToDoList();
  }

  void _toDoDeleteItem(String id) async {
    setState(() {
      todosList.removeWhere((item) => item.id == id);
    });
    //строчка ниже нужна для того, чтобы удалялся элемент во время поиска
    setState(() {
      _foundToDo.removeWhere((item) => item.id == id);
    });
    await _saveToDoList();
  }

  void _runFilter(String enteredKeyword){
    List<ToDo> results = [];
    if(enteredKeyword.isEmpty){
      results = todosList;
    } else {
      results = todosList.where((item) => item.todoText!.toLowerCase().contains(enteredKeyword.toLowerCase())).toList();
    }
    results.sort((a, b) {
      // Сначала сравниваем выполненные задачи, чтобы они были внизу
      if (a.isDone != b.isDone) {
        return a.isDone ? -1 : 1;
      }
      // Затем сравниваем по идентификатору задачи
      return a.id!.compareTo(b.id!);
    });
    setState(() {
      _foundToDo = results;
    });
  }

  Future<void> _saveToDoList() async {
    final jsonList = todosList.map((todo) => todo.toJson()).toList();
    await _prefs.setString('todos', json.encode(jsonList));
  }

  Future<void> _loadToDoList() async {
    _prefs = await SharedPreferences.getInstance();
    final jsonString = _prefs.getString('todos');
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      final List<ToDo> loadedList = jsonList.map((json) => ToDo.fromJson(json)).toList();
      setState(() {
        todosList = loadedList;
        _foundToDo = loadedList;
      });
    }
  }

  void _addToDoItem(String toDo) async {
    setState(() {
      final newNote = ToDo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        todoText: toDo,
      );
      todosList.insert(0,newNote);
    });
    _todoController.clear();
    await _saveToDoList();
    _runFilter(_todoController.text);
  }

  Widget searchBox() {
    return Container(
      decoration: BoxDecoration(
          color: tdWhite, borderRadius: BorderRadius.circular(20)),
      child: TextField(
        onChanged: (value)=> _runFilter(value),
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.all(0),
          prefixIcon: Icon(
            Icons.search,
            color: tdBlack,
            size: 20,
          ),
          prefixIconConstraints: BoxConstraints(maxHeight: 20, minWidth: 50),
          border: InputBorder.none,
          hintText: 'Поиск',
          hintStyle: TextStyle(color: tdGrey),
        ),
      ),
    );
  }
}
