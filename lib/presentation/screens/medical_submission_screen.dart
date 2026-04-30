import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../providers/auth_provider.dart';
import '../../providers/medical_provider.dart';
import '../../domain/models/medical_submission.dart';
import '../../app/theme.dart';

class MedicalSubmissionScreen extends StatefulWidget {
  const MedicalSubmissionScreen({super.key});

  @override
  State<MedicalSubmissionScreen> createState() => _MedicalSubmissionScreenState();
}

class _MedicalSubmissionScreenState extends State<MedicalSubmissionScreen> {
  final _formKey = GlobalKey<FormState>();
  int _selectedWeek = 1;
  DateTime _selectedDate = DateTime.now();
  String _mockPhotoPath = '';
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        context.read<MedicalProvider>().loadSubmissionsForUser(user.id);
      }
    });
  }

  Future<void> _pickPhoto() async {
    setState(() => _isUploading = true);
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      
      if (image != null) {
        setState(() {
          _mockPhotoPath = image.path;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Photo attached successfully!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open camera: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2025),
      lastDate: DateTime(2027),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitMedical() {
    if (!_formKey.currentState!.validate()) return;
    if (_mockPhotoPath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a photo of your medical certificate.')),
      );
      return;
    }

    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    final submission = MedicalSubmission(
      id: 'med-${DateTime.now().millisecondsSinceEpoch}',
      userId: user.id,
      week: _selectedWeek,
      date: '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
      photoPath: _mockPhotoPath,
      status: 'pending',
    );

    context.read<MedicalProvider>().addSubmission(submission).then((_) {
      final error = context.read<MedicalProvider>().errorMessage;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medical submitted successfully. Waiting for Admin approval.')),
        );
        setState(() {
          _mockPhotoPath = '';
          _selectedWeek = 1;
        });
      }
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MedicalProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Submissions'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Submission Form
            Form(
              key: _formKey,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Submit New Medical', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _selectedWeek,
                      decoration: const InputDecoration(labelText: 'Academic Week'),
                      items: List.generate(15, (index) => index + 1)
                          .map((w) => DropdownMenuItem(value: w, child: Text('Week $w')))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedWeek = val!),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Date of Medical'),
                      subtitle: Text('${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}'),
                      trailing: const Icon(Icons.calendar_today, color: AppTheme.primary),
                      onTap: () => _selectDate(context),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: _isUploading
                          ? const CircularProgressIndicator()
                          : ElevatedButton.icon(
                              onPressed: _pickPhoto,
                              icon: Icon(_mockPhotoPath.isNotEmpty ? Icons.check_circle : Icons.camera_alt),
                              label: Text(_mockPhotoPath.isNotEmpty ? 'Retake Photo' : 'Open Camera'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _mockPhotoPath.isNotEmpty ? Colors.green : AppTheme.primary,
                                foregroundColor: Colors.white,
                              ),
                            ),
                    ),
                    if (_mockPhotoPath.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Center(
                          child: Text(
                            'File: ${_mockPhotoPath.split('/').last}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitMedical,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('SUBMIT'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text('Previous Submissions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (provider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (provider.submissions.isEmpty)
              const Center(child: Text('No medical records submitted yet.', style: TextStyle(color: Colors.grey)))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.submissions.length,
                itemBuilder: (context, index) {
                  final sub = provider.submissions[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Icon(Icons.description, color: _getStatusColor(sub.status)),
                      title: Text('Week ${sub.week} Medical'),
                      subtitle: Text('Date: ${sub.date}'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(sub.status).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          sub.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(sub.status),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
