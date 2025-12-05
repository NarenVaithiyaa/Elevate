import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Habit {
  final String id;
  final String title;
  final String description;
  final int colorValue;
  final int iconCodePoint;
  final String frequency;
  final List<DateTime> completedDates;
  final DateTime? createdAt;

  Habit({
    required this.id,
    required this.title,
    required this.description,
    required this.colorValue,
    required this.iconCodePoint,
    this.frequency = 'Every day',
    this.completedDates = const [],
    this.createdAt,
  });

  Color get color => Color(colorValue);
  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  bool isCompletedToday() {
    final now = DateTime.now();
    return completedDates.any((date) =>
        date.year == now.year &&
        date.month == now.month &&
        date.day == now.day);
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'colorValue': colorValue,
      'iconCodePoint': iconCodePoint,
      'frequency': frequency,
      'completedDates': completedDates.map((e) => Timestamp.fromDate(e)).toList(),
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map, String id) {
    return Habit(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      colorValue: map['colorValue'] ?? 0xFF2196F3,
      iconCodePoint: map['iconCodePoint'] ?? 57565, // Default to some icon
      frequency: map['frequency'] ?? 'Every day',
      completedDates: (map['completedDates'] as List<dynamic>?)
              ?.map((e) => (e as Timestamp).toDate())
              .toList() ??
          [],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Habit copyWith({
    String? id,
    String? title,
    String? description,
    int? colorValue,
    int? iconCodePoint,
    String? frequency,
    List<DateTime>? completedDates,
    DateTime? createdAt,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      colorValue: colorValue ?? this.colorValue,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      frequency: frequency ?? this.frequency,
      completedDates: completedDates ?? this.completedDates,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
