import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: ExpenseTracker(),
    );
  }
}

class Expense {
  final String category;
  final double amount;
  final String description;

  Expense({
    required this.category,
    required this.amount,
    required this.description,
  });
}

class ExpenseTracker extends StatefulWidget {
  @override
  _ExpenseTrackerState createState() => _ExpenseTrackerState();
}

class _ExpenseTrackerState extends State<ExpenseTracker> {
  double _monthlyBudget = 0.0;
  double _totalExpenses = 0.0;

  final List<Expense> _expenses = [];
  String _selectedCategory = 'Food';

  final List<String> _categories = [
    'Food',
    'Transport',
    'Entertainment',
    'Shopping',
    'Bills',
    'Other'
  ];

  void _showBudgetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController _budgetController = TextEditingController();
        return AlertDialog(
          title: Text('Set Monthly Budget'),
          content: TextField(
            controller: _budgetController,
            decoration: InputDecoration(
              labelText: 'Budget Amount',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_budgetController.text.isNotEmpty) {
                  setState(() {
                    _monthlyBudget = double.parse(_budgetController.text);
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Set Budget'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showExpenseDialog() {
    final TextEditingController _amountController = TextEditingController();
    final TextEditingController _descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Expense'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_amountController.text.isNotEmpty &&
                    _descriptionController.text.isNotEmpty) {
                  setState(() {
                    double amount = double.parse(_amountController.text);
                    _expenses.add(Expense(
                      category: _selectedCategory,
                      amount: amount,
                      description: _descriptionController.text,
                    ));
                    _totalExpenses += amount;
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add Expense'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Expense Tracker'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Add Expense'),
              Tab(text: 'Transactions'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: _showBudgetDialog,
                    child: Text('Set Monthly Budget'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _showExpenseDialog,
                    child: Text('Add Expense'),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Total Expenses: \₹$_totalExpenses',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Remaining Budget: \₹${_monthlyBudget - _totalExpenses}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monthly Budget: \₹$_monthlyBudget',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Total Expenses: \₹$_totalExpenses',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Remaining Budget: \₹${_monthlyBudget - _totalExpenses}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16.0),
                    itemCount: _expenses.length,
                    itemBuilder: (context, index) {
                      final expense = _expenses[index];
                      return Card(
                        child: ListTile(
                          title: Text('${expense.category}: \₹${expense.amount}'),
                          subtitle: Text(expense.description),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
