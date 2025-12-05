import 'package:cloud_firestore/cloud_firestore.dart';

enum EisenhowerQuadrant {
  doFirst, // Urgent & Important
  schedule, // Important & Not Urgent
  delegate, // Urgent & Not Important
  delete, // Not Urgent & Not Important
}

class Task {
  final String id;
  final String title;
  final String notes;
  final DateTime dueDate;
  final bool isImportant;
  final bool isUrgent;
  final bool isCompleted;
  final DateTime? createdAt;

  Task({
    required this.id,
    required this.title,
    this.notes = '',
    required this.dueDate,
    this.isImportant = false,
    this.isUrgent = false,
    this.isCompleted = false,
    this.createdAt,
  });

  EisenhowerQuadrant get quadrant {
    if (isImportant && isUrgent) return EisenhowerQuadrant.doFirst;
    if (isImportant && !isUrgent) return EisenhowerQuadrant.schedule;
    if (!isImportant && isUrgent) return EisenhowerQuadrant.delegate;
    return EisenhowerQuadrant.delete;
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'notes': notes,
      'dueDate': Timestamp.fromDate(dueDate),
      'isImportant': isImportant,
      'isUrgent': isUrgent,
      'isCompleted': isCompleted,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map, String id) {
    return Task(
      id: id,
      title: map['title'] ?? '',
      notes: map['notes'] ?? '',
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      isImportant: map['isImportant'] ?? false,
      isUrgent: map['isUrgent'] ?? false,
      isCompleted: map['isCompleted'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Task copyWith({
    String? id,
    String? title,
    String? notes,
    DateTime? dueDate,
    bool? isImportant,
    bool? isUrgent,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      dueDate: dueDate ?? this.dueDate,
      isImportant: isImportant ?? this.isImportant,
      isUrgent: isUrgent ?? this.isUrgent,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
