import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(CuroAIApp());

class CuroAIApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CuroAI',
      home: GoalSubmissionPage(),
    );
  }
}

class GoalSubmissionPage extends StatefulWidget {
  @override
  _GoalSubmissionPageState createState() => _GoalSubmissionPageState();
}

class _GoalSubmissionPageState extends State<GoalSubmissionPage> {
  final TextEditingController _goalController = TextEditingController();
  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now().add(Duration(days: 1)),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  Future<void> _submitGoal() async {
    final goal = _goalController.text;
    final deadline = _selectedDate != null
        ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
        : null;

    if (goal.isEmpty || deadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter goal and pick a deadline')),
      );
      return;
    }

    final url = Uri.parse('https://curoai.free.beeceptor.com/goals');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'goal': goal, 'deadline': deadline}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Goal submitted successfully!')),
      );
      _goalController.clear();
      setState(() {
        _selectedDate = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit. Try again later.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('CuroAI Goal Planner')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _goalController,
              decoration: InputDecoration(
                labelText: 'Enter your goal',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDate == null
                        ? 'No deadline selected'
                        : 'Deadline: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}',
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: Text('Pick Deadline'),
                ),
              ],
            ),
            Spacer(),
            ElevatedButton(
              onPressed: _submitGoal,
              child: Text('Create My Plan'),
              style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(50)),
            )
          ],
        ),
      ),
    );
  }
}
