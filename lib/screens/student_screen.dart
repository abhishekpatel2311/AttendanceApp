import 'package:flutter/material.dart';
import '../models/db_helper.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  final _dbHelper = DBHelper();
  final _nameController = TextEditingController();
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _filteredStudents = [];

  Future<void> _refreshStudents() async {
    final data = await _dbHelper.query(DBHelper.studentTable);
    setState(() {
      _students = data;
      _filteredStudents = data;
    });
  }

  void _filterStudents(String query) {
    final results = _students.where((student) {
      final name = student['name'].toLowerCase();
      final input = query.toLowerCase();
      return name.contains(input);
    }).toList();

    setState(() {
      _filteredStudents = results;
    });
  }

  Future<void> _addStudent() async {
    if (_nameController.text.isEmpty) return;
    await _dbHelper
        .insert(DBHelper.studentTable, {'name': _nameController.text});
    _nameController.clear();
    _refreshStudents();
  }

  @override
  void initState() {
    super.initState();
    _refreshStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Students')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(labelText: 'Search Students'),
              onChanged: _filterStudents,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Student Name'),
            ),
          ),
          ElevatedButton(
              onPressed: _addStudent, child: const Text('Add Student')),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredStudents.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_filteredStudents[index]['name']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
