import 'dart:async';
import 'package:flutter/material.dart';
import 'package:habit_tracker_mvp/models/habit.dart';
import 'package:habit_tracker_mvp/models/task.dart';
import 'package:habit_tracker_mvp/services/firestore_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  bool _biometricEnabled = false;
  bool get biometricEnabled => _biometricEnabled;

  bool _notificationsEnabled = false;
  bool get notificationsEnabled => _notificationsEnabled;
  
  FirestoreService? _firestoreService;
  StreamSubscription<List<Habit>>? _habitsSubscription;
  StreamSubscription<List<Task>>? _tasksSubscription;

  AppState() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _biometricEnabled = prefs.getBool('biometric_enabled') ?? false;
    _isDarkMode = prefs.getBool('is_dark_mode') ?? false;
    _notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
    notifyListeners();
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    _biometricEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', enabled);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', _isDarkMode);
    notifyListeners();
  }

  List<Habit> _habits = [];
  List<Task> _tasks = [];

  List<Habit> get habits => _habits;
  List<Task> get tasks => _tasks;

  void initialize(String userId) {
    _firestoreService = FirestoreService(uid: userId);
    
    _habitsSubscription?.cancel();
    _habitsSubscription = _firestoreService!.getHabitsStream().listen((habits) {
      _habits = habits;
      notifyListeners();
    });

    _tasksSubscription?.cancel();
    _tasksSubscription = _firestoreService!.getTasksStream().listen((tasks) {
      _tasks = tasks;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _habitsSubscription?.cancel();
    _tasksSubscription?.cancel();
    super.dispose();
  }

  Future<void> toggleHabitCompletion(String id) async {
    if (_firestoreService == null) return;
    
    final index = _habits.indexWhere((h) => h.id == id);
    if (index != -1) {
      final habit = _habits[index];
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      List<DateTime> newDates = List.from(habit.completedDates);
      
      // Check if already completed today
      final todayIndex = newDates.indexWhere((date) => 
        date.year == today.year && 
        date.month == today.month && 
        date.day == today.day
      );

      if (todayIndex != -1) {
        newDates.removeAt(todayIndex);
      } else {
        newDates.add(now);
      }

      await _firestoreService!.updateHabit(habit.copyWith(completedDates: newDates));
      print("Habit completion toggled: ${habit.title}, Completed: ${todayIndex == -1}");
    }
  }

  Future<void> addHabit(String title, String description, Color color, IconData icon, String frequency) async {
    if (_firestoreService == null) {
      print("Error: FirestoreService is null in addHabit");
      return;
    }
    
    final habit = Habit(
      id: '',
      title: title,
      description: description,
      colorValue: color.value,
      iconCodePoint: icon.codePoint,
      frequency: frequency,
      completedDates: [],
      createdAt: DateTime.now(),
    );
    
    try {
      await _firestoreService!.createHabit(habit);
      print("Habit added successfully: $title");
    } catch (e) {
      print("Error adding habit: $e");
    }
  }

  Future<void> updateHabit(String id, String title, String description, Color color, IconData icon, String frequency) async {
    if (_firestoreService == null) return;

    final index = _habits.indexWhere((h) => h.id == id);
    if (index != -1) {
      final habit = _habits[index].copyWith(
        title: title,
        description: description,
        colorValue: color.value,
        iconCodePoint: icon.codePoint,
        frequency: frequency,
      );
      try {
        await _firestoreService!.updateHabit(habit);
        print("Habit updated successfully: $title");
      } catch (e) {
        print("Error updating habit: $e");
      }
    }
  }

  Future<void> deleteHabit(String id) async {
    if (_firestoreService == null) return;
    try {
      await _firestoreService!.deleteHabit(id);
      print("Habit deleted successfully: $id");
    } catch (e) {
      print("Error deleting habit: $e");
    }
  }

  Future<void> addTask(String title, String notes, DateTime dueDate, bool isImportant, bool isUrgent) async {
    if (_firestoreService == null) return;

    final task = Task(
      id: '',
      title: title,
      notes: notes,
      dueDate: dueDate,
      isImportant: isImportant,
      isUrgent: isUrgent,
      isCompleted: false,
      createdAt: DateTime.now(),
    );

    await _firestoreService!.createTask(task);
  }

  Future<void> updateTask(String id, String title, String notes, DateTime dueDate, bool isImportant, bool isUrgent) async {
    if (_firestoreService == null) return;

    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final task = _tasks[index].copyWith(
        title: title,
        notes: notes,
        dueDate: dueDate,
        isImportant: isImportant,
        isUrgent: isUrgent,
      );
      await _firestoreService!.updateTask(task);
    }
  }

  Future<void> toggleTaskCompletion(String id) async {
    if (_firestoreService == null) return;

    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final task = _tasks[index];
      await _firestoreService!.updateTask(task.copyWith(isCompleted: !task.isCompleted));
    }
  }

  Future<void> deleteTask(String id) async {
    if (_firestoreService == null) return;
    await _firestoreService!.deleteTask(id);
  }
}

