import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habit_tracker_mvp/models/habit.dart';
import 'package:habit_tracker_mvp/models/task.dart';

class FirestoreService {
  final String uid;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  FirestoreService({required this.uid});

  // --- Collections ---
  CollectionReference get _habitsRef {
    return _db.collection('users').doc(uid).collection('habits');
  }

  CollectionReference get _tasksRef {
    return _db.collection('users').doc(uid).collection('tasks');
  }

  // --- Habits CRUD ---

  Future<void> createHabit(Habit habit) async {
    if (habit.id.isEmpty) {
      final docRef = _habitsRef.doc();
      final newHabit = habit.copyWith(id: docRef.id);
      await docRef.set(newHabit.toMap());
    } else {
      await _habitsRef.doc(habit.id).set(habit.toMap());
    }
  }

  Future<void> updateHabit(Habit habit) async {
    await _habitsRef.doc(habit.id).update(habit.toMap());
  }

  Future<void> deleteHabit(String habitId) async {
    await _habitsRef.doc(habitId).delete();
  }

  Stream<List<Habit>> getHabitsStream() {
    return _habitsRef.orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Habit.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // --- Tasks CRUD ---

  Future<void> createTask(Task task) async {
    if (task.id.isEmpty) {
      final docRef = _tasksRef.doc();
      final newTask = task.copyWith(id: docRef.id);
      await docRef.set(newTask.toMap());
    } else {
      await _tasksRef.doc(task.id).set(task.toMap());
    }
  }

  Future<void> updateTask(Task task) async {
    await _tasksRef.doc(task.id).update(task.toMap());
  }

  Future<void> deleteTask(String taskId) async {
    await _tasksRef.doc(taskId).delete();
  }

  Stream<List<Task>> getTasksStream() {
    return _tasksRef.orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Task.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}
