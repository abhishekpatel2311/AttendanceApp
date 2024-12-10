import 'package:flutter/material.dart';
import '../models/db_helper.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final _dbHelper = DBHelper();
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _subjects = [];
  String? _selectedSubject;
  DateTime _selectedDate = DateTime.now();

  Future<void> _refreshData() async {
    _students = await _dbHelper.query(DBHelper.studentTable);
    _subjects = await _dbHelper.query(DBHelper.subjectTable);
    setState(() {});
  }

  Future<void> _markAttendance(int studentId, int status) async {
    final subjectId =
        _subjects.firstWhere((sub) => sub['name'] == _selectedSubject)['id'];
    await _dbHelper.insert(DBHelper.attendanceTable, {
      'studentId': studentId,
      'subjectId': subjectId,
      'date': _selectedDate.toIso8601String(),
      'status': status
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mark Attendance')),
      body: Column(
        children: [
          DropdownButton<String>(
            value: _selectedSubject,
            hint: const Text('Select Subject'),
            items: _subjects.map((subject) {
              return DropdownMenuItem<String>(
                value: subject['name'],
                child: Text(subject['name']),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedSubject = value;
              });
            },
          ),
          ElevatedButton(
            onPressed: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (pickedDate != null) {
                setState(() {
                  _selectedDate = pickedDate;
                });
              }
            },
            child:
                Text('Select Date: ${_selectedDate.toLocal()}'.split(' ')[0]),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _students.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_students[index]['name']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () =>
                            _markAttendance(_students[index]['id'], 1),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () =>
                            _markAttendance(_students[index]['id'], 0),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
