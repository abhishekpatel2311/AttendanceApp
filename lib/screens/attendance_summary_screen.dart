import 'package:flutter/material.dart';
import '../models/db_helper.dart';

class AttendanceSummaryScreen extends StatefulWidget {
  const AttendanceSummaryScreen({super.key});

  @override
  State<AttendanceSummaryScreen> createState() =>
      _AttendanceSummaryScreenState();
}

class _AttendanceSummaryScreenState extends State<AttendanceSummaryScreen> {
  final _dbHelper = DBHelper();
  String? _selectedSubject;
  List<Map<String, dynamic>> _subjects = [];
  Map<String, double> _summary = {};

  // Load subjects from the database
  Future<void> _loadSubjects() async {
    final data = await _dbHelper.query(DBHelper.subjectTable);
    setState(() {
      _subjects = data;
    });
  }

  Future<void> _calculateAttendance() async {
    if (_selectedSubject == null) return;

    final subject = _subjects.firstWhere(
      (subj) => subj['name'] == _selectedSubject,
      orElse: () => {},
    );

    if (subject.isEmpty) return;

    final subjectId = subject['id'];
    final attendance = await _dbHelper.query(DBHelper.attendanceTable);
    final students = await _dbHelper.query(DBHelper.studentTable);

    Map<String, double> result = {};

    for (var student in students) {
      final studentAttendance = attendance.where(
        (att) =>
            att['studentId'] == student['id'] && att['subjectId'] == subjectId,
      );

      final total = studentAttendance.length;
      final present =
          studentAttendance.where((att) => att['status'] == 1).length;

      result[student['name']] = total > 0 ? (present / total) * 100 : 0.0;
    }

    setState(() {
      _summary = result;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance Summary')),
      body: Column(
        children: [
          // Dropdown for selecting subject
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: _selectedSubject,
              hint: const Text('Select Subject'),
              items: _subjects.isNotEmpty
                  ? _subjects.map((subject) {
                      return DropdownMenuItem<String>(
                        value: subject['name'],
                        child: Text(subject['name'] ?? 'Unknown'),
                      );
                    }).toList()
                  : [],
              onChanged: (value) {
                setState(() {
                  _selectedSubject = value;
                  _calculateAttendance();
                });
              },
              isExpanded: true,
            ),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: _summary.isEmpty
                ? const Center(child: Text('No data available.'))
                : ListView(
                    children: _summary.entries.map((entry) {
                      return ListTile(
                        title: Text(entry.key),
                        subtitle: Text(
                            'Attendance: ${entry.value.toStringAsFixed(2)}%'),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
