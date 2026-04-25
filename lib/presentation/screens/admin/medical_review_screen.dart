import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/medical_provider.dart';
import '../../../app/theme.dart';

class MedicalReviewScreen extends StatefulWidget {
  const MedicalReviewScreen({super.key});

  @override
  State<MedicalReviewScreen> createState() => _MedicalReviewScreenState();
}

class _MedicalReviewScreenState extends State<MedicalReviewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MedicalProvider>().loadAllSubmissions();
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
        title: const Text('Review Medicals'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.submissions.isEmpty
              ? const Center(child: Text('No medical submissions recorded.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.submissions.length,
                  itemBuilder: (context, index) {
                    final sub = provider.submissions[index];
                    final isPending = sub.status == 'pending';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Student ID: ${sub.userId}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Container(
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
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Date of Medical: ${sub.date}'),
                            Text('Academic Week: ${sub.week}'),
                            const SizedBox(height: 8),
                            const Text('Attached Document:', style: TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Container(
                              height: 120,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.image, size: 32, color: Colors.grey),
                                    const SizedBox(height: 4),
                                    Text(
                                      sub.photoPath.split('/').last,
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (isPending) ...[
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => context.read<MedicalProvider>().rejectSubmission(sub.id),
                                      icon: const Icon(Icons.cancel, color: Colors.red),
                                      label: const Text('Reject', style: TextStyle(color: Colors.red)),
                                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => context.read<MedicalProvider>().approveSubmission(sub.id),
                                      icon: const Icon(Icons.check_circle),
                                      label: const Text('Approve'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
