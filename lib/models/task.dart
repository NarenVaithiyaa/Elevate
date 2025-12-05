
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
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    this.notes = '',
    required this.dueDate,
    this.isImportant = false,
    this.isUrgent = false,
    this.isCompleted = false,
  });

  EisenhowerQuadrant get quadrant {
    if (isImportant && isUrgent) return EisenhowerQuadrant.doFirst;
    if (isImportant && !isUrgent) return EisenhowerQuadrant.schedule;
    if (!isImportant && isUrgent) return EisenhowerQuadrant.delegate;
    return EisenhowerQuadrant.delete;
  }
}
