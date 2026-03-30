import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/results_provider.dart';
import '../../../domain/models/academic_result.dart';
import '../../../domain/models/user.dart';
import '../../../data/local/database_helper.dart';

class ResultsAdminScreen extends StatefulWidget {
  const ResultsAdminScreen({super.key});

  @override
  State<ResultsAdminScreen> createState() => _ResultsAdminScreenState();
}

class _ResultsAdminScreenState extends State<ResultsAdminScreen> {
  List<User> _students = [];
  User? _selectedStudent;
  bool _isLoadingStudents = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('users', where: 'role = ?', whereArgs: ['student']);
    setState(() {
      _students = rows.map((r) => User.fromMap(r)).toList();
      _isLoadingStudents = false;
    });
  }

  void _selectStudent(User student) {
    setState(() {
      _selectedStudent = student;
    });
    context.read<ResultsProvider>().loadUserResults(student.id);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ResultsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Results Management'),
        actions: [
          if (_selectedStudent != null)
            IconButton(
              icon: const Icon(Icons.people),
              onPressed: () => setState(() => _selectedStudent = null),
            ),
        ],
      ),
      body: _isLoadingStudents
          ? const Center(child: CircularProgressIndicator())
          : _selectedStudent == null
              ? _buildStudentList()
              : _buildResultsEditor(provider),
      floatingActionButton: _selectedStudent != null
          ? FloatingActionButton(
              onPressed: () => _showResultDialog(null),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildStudentList() {
    return ListView.builder(
      itemCount: _students.length,
      itemBuilder: (context, index) {
        final student = _students[index];
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.school)),
          title: Text(student.name),
          subtitle: Text(student.email),
          onTap: () => _selectStudent(student),
        );
      },
    );
  }

  Widget _buildResultsEditor(ResultsProvider provider) {
    return Column(
      children: [
        ListTile(
          tileColor: Colors.blue.withValues(alpha: 0.1),
          title: Text('Student: ${_selectedStudent!.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: const Text('Enter and edit grades for this student.'),
        ),
        Expanded(
          child: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.results.isEmpty
                  ? const Center(child: Text('No results recorded for this student.'))
                  : ListView.builder(
                      itemCount: provider.results.length,
                      itemBuilder: (context, index) {
                        final res = provider.results[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: ListTile(
                            title: Text(res.subject, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Semester: ${res.semester} • Grade: ${res.grade} (GPA: ${res.gpa})'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _showResultDialog(res),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => provider.deleteResult(res.id!),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  void _showResultDialog(AcademicResult? result) {
    final subjectCtrl = TextEditingController(text: result?.subject);
    final semesterCtrl = TextEditingController(text: result?.semester.toString() ?? '1');
    final gradeCtrl = TextEditingController(text: result?.grade ?? 'A');
    final gpaCtrl = TextEditingController(text: result?.gpa.toString() ?? '4.0');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(result == null ? 'Add Result' : 'Edit Result'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: subjectCtrl, decoration: const InputDecoration(labelText: 'Subject')),
              TextField(controller: semesterCtrl, decoration: const InputDecoration(labelText: 'Semester'), keyboardType: TextInputType.number),
              TextField(controller: gradeCtrl, decoration: const InputDecoration(labelText: 'Grade (e.g. A-, B+)')),
              TextField(controller: gpaCtrl, decoration: const InputDecoration(labelText: 'GPA (e.g. 3.7)'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newResult = AcademicResult(
                id: result?.id,
                subject: subjectCtrl.text,
                semester: int.parse(semesterCtrl.text),
                grade: gradeCtrl.text,
                gpa: double.parse(gpaCtrl.text),
                userId: _selectedStudent!.id,
              );
              if (result == null) {
                context.read<ResultsProvider>().addResult(newResult);
              } else {
                context.read<ResultsProvider>().updateResult(newResult);
              }
              Navigator.pop(ctx);
            },
            child: Text(result == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }
}
