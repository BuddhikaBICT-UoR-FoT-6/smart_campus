// =============================================================================
// domain/models/campus_contact.dart
// =============================================================================

import 'user.dart';

class CampusContact {
  final String id;
  final String name;
  final String title;
  final String email;
  final String phone;
  final String category; // e.g., 'Administration', 'ICT Department', 'Security'
  final UserRole addedByRole; // The role that managed this contact

  const CampusContact({
    required this.id,
    required this.name,
    required this.title,
    required this.email,
    required this.phone,
    required this.category,
    required this.addedByRole,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'email': email,
      'phone': phone,
      'category': category,
      'addedByRole': addedByRole.name,
    };
  }

  factory CampusContact.fromMap(Map<String, dynamic> map) {
    return CampusContact(
      id: map['id'] as String,
      name: map['name'] as String,
      title: map['title'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      category: map['category'] as String,
      addedByRole: UserRole.values.byName(map['addedByRole'] as String),
    );
  }

  CampusContact copyWith({
    String? name,
    String? title,
    String? email,
    String? phone,
    String? category,
    UserRole? addedByRole,
  }) {
    return CampusContact(
      id: id,
      name: name ?? this.name,
      title: title ?? this.title,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      category: category ?? this.category,
      addedByRole: addedByRole ?? this.addedByRole,
    );
  }
}
