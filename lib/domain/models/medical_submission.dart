class MedicalSubmission {
  final String id;
  final String userId;
  final int week;
  final String date;
  final String photoPath;
  final String status; // 'pending', 'approved', 'rejected'

  const MedicalSubmission({
    required this.id,
    required this.userId,
    required this.week,
    required this.date,
    required this.photoPath,
    this.status = 'pending',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'week': week,
      'date': date,
      'photoPath': photoPath,
      'status': status,
    };
  }

  factory MedicalSubmission.fromMap(Map<String, dynamic> map) {
    return MedicalSubmission(
      id: map['id'] as String,
      userId: map['userId'] as String,
      week: map['week'] as int,
      date: map['date'] as String,
      photoPath: map['photoPath'] as String,
      status: map['status'] as String? ?? 'pending',
    );
  }

  MedicalSubmission copyWith({
    String? status,
  }) {
    return MedicalSubmission(
      id: id,
      userId: userId,
      week: week,
      date: date,
      photoPath: photoPath,
      status: status ?? this.status,
    );
  }
}
