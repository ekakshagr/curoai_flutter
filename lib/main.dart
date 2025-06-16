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
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Montserrat',
        scaffoldBackgroundColor: Color(0xFF1A1A2E),
        primaryColor: Color(0xFF9D4EDD),
        cardColor: Color(0xFF2A2A40),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF9D4EDD),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            padding: EdgeInsets.symmetric(vertical: 16),
            elevation: 4,
            shadowColor: Colors.purple.shade900,
            textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF2A2A40),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Color(0xFF9D4EDD), width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Color(0xFF7B2CBF), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Color(0xFF9D4EDD), width: 2),
          ),
          labelStyle: TextStyle(color: Colors.white70),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Color(0xFF7B2CBF),
          contentTextStyle: TextStyle(color: Colors.white),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF2A2A40),
          foregroundColor: Colors.white,
          elevation: 4,
        ),
      ),
      home: GoalSubmissionPage(),
      debugShowCheckedModeBanner: false,
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Color(0xFF9D4EDD),
              onPrimary: Colors.white,
              surface: Color(0xFF2A2A40),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Color(0xFF2A2A40),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Color(0xFF9D4EDD)),
            ),
          ),
          child: child!,
        );
      },
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Goal submitted successfully!')));
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
      appBar: AppBar(
        title: Text(
          '🎯 CuroAI Planner',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Container(
              padding: EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3C096C), Color(0xFF1A1A2E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "What's your next big goal?",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  TextField(
                    controller: _goalController,
                    decoration: InputDecoration(
                      labelText: 'Enter your goal',
                      prefixIcon: Icon(
                        Icons.flag_rounded,
                        color: Color(0xFF9D4EDD),
                      ),
                    ),
                    maxLines: 3,
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 24),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFF1A1A2E),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Color(0xFF9D4EDD),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            color: Color(0xFF9D4EDD),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _selectedDate == null
                                  ? 'Pick a deadline'
                                  : 'Deadline: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}',
                              style: TextStyle(
                                fontSize: 16,
                                color: _selectedDate == null
                                    ? Colors.white54
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 36),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _submitGoal,
                      icon: Icon(Icons.check_circle_outline),
                      label: Text('Create My Plan'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
