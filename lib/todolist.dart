import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'CompletedTaskPage.dart';

class TodoList extends StatefulWidget {
  const TodoList({super.key});

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  TextEditingController taskController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController editTaskController = TextEditingController();
  TextEditingController editDescriptionController = TextEditingController();
  bool isCompleted = false;
  List<Map<String, dynamic>> list = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  void dispose() {
    taskController.dispose();
    descriptionController.dispose();
    editTaskController.dispose();
    editDescriptionController.dispose();
    super.dispose();
  }

  Future<void> getData() async {
    setState(() {
      isLoading = true;
    });
    final url = 'https://api.nstack.in/v1/todos?page=1&limit=10';
    final uri = Uri.parse(url);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json['items'] as List;
      setState(() {
        list = result.cast<Map<String, dynamic>>();
        isLoading = false;
      });
    } else {
      // Handle error
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> addTask() async {
    final tsk = taskController.text;
    final des = descriptionController.text;
    final body = {
      "title": tsk,
      "description": des,
      "is_completed": isCompleted
    };

    final url = 'https://api.nstack.in/v1/todos';
    final uri = Uri.parse(url);
    final response = await http.post(uri, body: jsonEncode(body), headers: {
      'Content-Type': 'application/json'
    });

    if (response.statusCode == 201) {
      getData();
    } else {
      // Handle error
    }
  }

  Future<void> editTask(String id) async {
    final tsk = editTaskController.text;
    final des = editDescriptionController.text;
    final body = {
      "title": tsk,
      "description": des,
      "is_completed": isCompleted
    };

    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.put(uri, body: jsonEncode(body), headers: {
      'Content-Type': 'application/json'
    });

    if (response.statusCode == 200) {
      getData();
    } else {
      // Handle error
    }
  }

  Future<void> deleteTask(String id) async {
    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.delete(uri);

    if (response.statusCode == 200) {
      setState(() {
        list.removeWhere((element) => element['_id'] == id);
      });
    } else {
      // Handle error
    }
  }

  Future<void> markAsDone(String id) async {
    final item = list.firstWhere((element) => element['_id'] == id);
    final body = {
      "title": item['title'],
      "description": item['description'],
      "is_completed": true
    };

    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.put(uri, body: jsonEncode(body), headers: {
      'Content-Type': 'application/json'
    });

    if (response.statusCode == 200) {
      getData();
    } else {
      // Handle error
    }
  }

  void showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add Task"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: taskController,
                decoration: InputDecoration(
                  hintText: "Task",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  hintText: "Description",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            SizedBox(width: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  addTask();
                });
              },
              child: Text("Add Task"),
            ),
          ],
        );
      },
    );
  }

  void showEditTaskDialog(String title, String description, String id) {
    editTaskController.text = title;
    editDescriptionController.text = description;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit Task"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: editTaskController,
                decoration: InputDecoration(
                  hintText: "Task",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: editDescriptionController,
                decoration: InputDecoration(
                  hintText: "Description",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            SizedBox(width: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  editTask(id);
                });
              },
              child: Text("Update"),
            ),
          ],
        );
      },
    );
  }

  void navigateToCompletedTasks() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompletedTasksPage(
          completedTasks: list.where((task) => task['is_completed'] == true).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("To-Do List"),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.check_circle_outline),
            onPressed: navigateToCompletedTasks,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : list.isEmpty
          ? Center(
        child: Text(
          "No Tasks Available",
          style: TextStyle(fontSize: 30, color: Colors.grey),
        ),
      )
          : RefreshIndicator(
        onRefresh: getData,
        child: ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) {
            final item = list[index];
            final id = item['_id'];
            final isCompleted = item['is_completed'] ?? false;

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 5.0,
                color: isCompleted ? Colors.green.shade50 : Colors.white,
                child: ListTile(
                  leading: Icon(
                    isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isCompleted ? Colors.green : Colors.grey,
                  ),
                  title: Text(
                    item['title'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                    ),
                  ),
                  subtitle: Text(
                    item['description'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.done, color: Colors.green),
                        onPressed: () {
                          if (!isCompleted) {
                            markAsDone(id);
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          showEditTaskDialog(item['title'], item['description'], id);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          deleteTask(id);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddTaskDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}
