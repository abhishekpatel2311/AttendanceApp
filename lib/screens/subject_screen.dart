import 'package:flutter/material.dart';
import '../models/db_helper.dart';

class SubjectScreen extends StatefulWidget {
  const SubjectScreen({super.key});

  @override
  State<SubjectScreen> createState() => _SubjectScreenState();
}

class _SubjectScreenState extends State<SubjectScreen> {
  final _dbHelper = DBHelper();
  final _nameController = TextEditingController();
  List<Map<String, dynamic>> _subjects = [];

  Future<void> _refreshSubjects() async {
    final data = await _dbHelper.query(DBHelper.subjectTable);
    setState(() {
      _subjects = data;
    });
  }

  Future<void> _addSubject() async {
    if (_nameController.text.isEmpty) return;
    await _dbHelper
        .insert(DBHelper.subjectTable, {'name': _nameController.text});
    _nameController.clear();
    _refreshSubjects();
  }

  @override
  void initState() {
    super.initState();
    _refreshSubjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Subjects')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Subject Name'),
            ),
          ),
          ElevatedButton(
              onPressed: _addSubject, child: const Text('Add Subject')),
          Expanded(
            child: ListView.builder(
              itemCount: _subjects.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_subjects[index]['name']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
