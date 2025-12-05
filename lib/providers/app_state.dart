import 'package:flutter/material.dart';
import 'package:habit_tracker_mvp/models/habit.dart';
import 'package:habit_tracker_mvp/models/task.dart';
import 'package:habit_tracker_mvp/theme/app_theme.dart';
import 'package:uuid/uuid.dart';

class AppState extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  final List<Habit> _habits = [
    Habit(
      id: '1',
      title: 'Reading',
      description: 'Read 20 pages',
      color: AppColors.cardYellow,
      icon: Icons.book,
      completedDates: [],
    ),
    Habit(
      id: '2',
      title: 'Household',
      description: 'Make bed in the morning',
      color: AppColors.cardGreen,
      icon: Icons.home,
      completedDates: [DateTime.now()],
    ),
    Habit(
      id: '3',
      title: 'Programming',
      description: 'Write mini-games',
      color: AppColors.cardGray,
      icon: Icons.computer,
      completedDates: [],
    ),
    Habit(
      id: '4',
      title: 'Positive thinking',
      description: 'Write affirmations',
      color: AppColors.cardBlue,
      icon: Icons.psychology,
      completedDates: [],
    ),
    Habit(
      id: '5',
      title: 'Financial literacy',
      description: 'Record expenses',
      color: AppColors.cardPink,
      icon: Icons.account_balance_wallet,
      completedDates: [DateTime.now()],
    ),
  ];

  final List<Task> _tasks = [
    Task(
      id: '1',
      title: 'Submit Project Report',
      dueDate: DateTime.now().add(const Duration(days: 1)),
      isImportant: true,
      isUrgent: true,
    ),
    Task(
      id: '2',
      title: 'Plan Q3 Strategy',
      dueDate: DateTime.now().add(const Duration(days: 3)),
      isImportant: true,
      isUrgent: false,
    ),
    Task(
      id: '3',
      title: 'Reply to emails',
      dueDate: DateTime.now(),
      isImportant: false,
      isUrgent: true,
    ),
    Task(
      id: '4',
      title: 'Organize desktop',
      dueDate: DateTime.now().add(const Duration(days: 5)),
      isImportant: false,
      isUrgent: false,
    ),
  ];

  List<Habit> get habits => _habits;
  List<Task> get tasks => _tasks;

  void toggleHabitCompletion(String id) {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index != -1) {
      final habit = _habits[index];
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      List<DateTime> newDates = List.from(habit.completedDates);
      
      if (habit.isCompletedToday()) {
        newDates.removeWhere((date) => 
          date.year == today.year && 
          date.month == today.month && 
          date.day == today.day);
      } else {
        newDates.add(today);
      }

      _habits[index] = Habit(
        id: habit.id,
        title: habit.title,
        description: habit.description,
        color: habit.color,
        icon: habit.icon,
        frequency: habit.frequency,
        completedDates: newDates,
      );
      notifyListeners();
    }
  }

  void toggleTaskCompletion(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void addTask(String title, String notes, DateTime dueDate, bool isImportant, bool isUrgent) {
    _tasks.add(Task(
      id: const Uuid().v4(),
      title: title,
      notes: notes,
      dueDate: dueDate,
      isImportant: isImportant,
      isUrgent: isUrgent,
    ));
    notifyListeners();
  }

  void updateTask(String id, String title, String notes, DateTime dueDate, bool isImportant, bool isUrgent) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final oldTask = _tasks[index];
      _tasks[index] = Task(
        id: id,
        title: title,
        notes: notes,
        dueDate: dueDate,
        isImportant: isImportant,
        isUrgent: isUrgent,
        isCompleted: oldTask.isCompleted,
      );
      notifyListeners();
    }
  }

  void addHabit(String title, String description, Color color, IconData icon, String frequency) {
    _habits.add(Habit(
      id: const Uuid().v4(),
      title: title,
      description: description,
      color: color,
      icon: icon,
      frequency: frequency,
    ));
    notifyListeners();
  }

  void updateHabit(String id, String title, String description, Color color, IconData icon, String frequency) {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index != -1) {
      final oldHabit = _habits[index];
      _habits[index] = Habit(
        id: id,
        title: title,
        description: description,
        color: color,
        icon: icon,
        frequency: frequency,
        completedDates: oldHabit.completedDates,
      );
      notifyListeners();
    }
  }

  void deleteHabit(String id) {
    _habits.removeWhere((h) => h.id == id);
    notifyListeners();
  }
}
