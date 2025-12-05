import 'package:flutter/material.dart';

class Habit {
  final String id;
  final String title;
  final String description;
  final Color color;
  final IconData icon;
  final String frequency; // 'Every day', 'Weekly', 'Custom'
  final List<DateTime> completedDates;

  Habit({
    required this.id,
    required this.title,
    required this.description,
    required this.color,
    required this.icon,
    this.frequency = 'Every day',
    this.completedDates = const [],
  });

  bool isCompletedToday() {
    final now = DateTime.now();
    return completedDates.any((date) =>
        date.year == now.year &&
        date.month == now.month &&
        date.day == now.day);
  }
}
