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
              heroTag: null,
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
        if (provider.results.isNotEmpty) Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.blue.shade800, Colors.blue.shade500]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Academic Standing', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('CGPA: ${provider.cgpa.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                      child: Text(provider.degreeClass, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('SGPA by Semester:', style: TextStyle(color: Colors.white70)),
                Wrap(
                  spacing: 8,
                  children: provider.sgpaBySemester.entries.map((e) => Chip(
                    label: Text('Sem ${e.key}: ${e.value.toStringAsFixed(2)}'),
                    backgroundColor: Colors.white,
                  )).toList(),
                )
              ],
            ),
          ),
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
                            subtitle: Text('Level: ${res.level} • Semester: ${res.semester}\nMarks: ${res.marks} • Credits: ${res.credits} • Grade: ${res.grade} (GPA: ${res.gpa})'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _showResultDialog(res),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => provider.deleteResult(res.id!, _selectedStudent!.id),
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
    final levelCtrl = TextEditingController(text: result?.level.toString() ?? '1');
    final semesterCtrl = TextEditingController(text: result?.semester.toString() ?? '1');
    final marksCtrl = TextEditingController(text: result?.marks.toString() ?? '0');
    final creditsCtrl = TextEditingController(text: result?.credits.toString() ?? '3');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(result == null ? 'Add Result' : 'Edit Result'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: subjectCtrl, decoration: const InputDecoration(labelText: 'Subject')),
              TextField(controller: levelCtrl, decoration: const InputDecoration(labelText: 'Level (e.g. 1, 2, 3)'), keyboardType: TextInputType.number),
              TextField(controller: semesterCtrl, decoration: const InputDecoration(labelText: 'Semester'), keyboardType: TextInputType.number),
              TextField(controller: marksCtrl, decoration: const InputDecoration(labelText: 'Marks (0-100)'), keyboardType: TextInputType.number),
              TextField(controller: creditsCtrl, decoration: const InputDecoration(labelText: 'Credits (e.g. 2, 3)'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final marks = int.tryParse(marksCtrl.text) ?? 0;
              final newResult = AcademicResult(
                id: result?.id,
                subject: subjectCtrl.text,
                level: int.tryParse(levelCtrl.text) ?? 1,
                semester: int.parse(semesterCtrl.text),
                marks: marks,
                credits: int.tryParse(creditsCtrl.text) ?? 3,
                grade: ResultsProvider.calculateGrade(marks),
                gpa: ResultsProvider.calculateGpa(marks),
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
