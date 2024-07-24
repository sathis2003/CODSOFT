import 'package:flutter/material.dart';

class CompletedTasksPage extends StatelessWidget {
  final List<Map<String, dynamic>> completedTasks;

  const CompletedTasksPage({super.key, required this.completedTasks});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Completed Tasks"),
        backgroundColor: Colors.green,
      ),
      body: completedTasks.isEmpty
          ? Center(
        child: Text(
          "No Completed Tasks",
          style: TextStyle(fontSize: 30, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: completedTasks.length,
        itemBuilder: (context, index) {
          final item = completedTasks[index];
          final id = item['_id'];

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 5.0,
              color: Colors.green.shade50,
              child: ListTile(
                leading: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
                title: Text(
                  item['title'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                subtitle: Text(
                  item['description'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.lineThrough,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _deleteTask(context, id);
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _deleteTask(BuildContext context, String id) {
    // Implement the delete action here
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Task"),
          content: Text("Are you sure you want to delete this task?"),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                // Call a method to delete the task from the server or local storage
                // For example:
                // deleteTask(id);
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}
