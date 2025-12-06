import 'package:flutter/material.dart';
import 'package:habit_tracker_mvp/models/task.dart';
import 'package:habit_tracker_mvp/providers/app_state.dart';
import 'package:habit_tracker_mvp/theme/app_theme.dart';
import 'package:habit_tracker_mvp/screens/add_task_sheet.dart';
import 'package:habit_tracker_mvp/screens/manage_tasks_screen.dart';
import 'package:habit_tracker_mvp/providers/calendar_provider.dart';
import 'package:habit_tracker_mvp/widgets/calendar_event_tile.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class TaskMatrixScreen extends StatefulWidget {
  const TaskMatrixScreen({super.key});

  @override
  State<TaskMatrixScreen> createState() => _TaskMatrixScreenState();
}

class _TaskMatrixScreenState extends State<TaskMatrixScreen> {
  bool _showCompleted = false;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final calendarProvider = Provider.of<CalendarProvider>(context);
    final allTasks = appState.tasks;
    
    // Filter tasks based on completion status if needed
    final tasks = _showCompleted 
        ? allTasks 
        : allTasks.where((t) => !t.isCompleted).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Matrix'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            tooltip: 'Manage Tasks',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ManageTasksScreen()),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              if (value == 'toggle_completed') {
                setState(() {
                  _showCompleted = !_showCompleted;
                });
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'toggle_completed',
                child: Row(
                  children: [
                    Icon(
                      _showCompleted ? Icons.check_box : Icons.check_box_outline_blank,
                      color: AppColors.accentPrimary,
                    ),
                    const SizedBox(width: 8),
                    const Text('Show Completed'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _buildQuadrant(
                    context,
                    'Important & Urgent',
                    AppColors.urgentImportant,
                    tasks.where((t) => t.quadrant == EisenhowerQuadrant.doFirst).toList(),
                  ),
                ),
                Expanded(
                  child: _buildQuadrant(
                    context,
                    'Important & Not Urgent',
                    AppColors.important,
                    tasks.where((t) => t.quadrant == EisenhowerQuadrant.schedule).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _buildQuadrant(
                    context,
                    'Not Important & Urgent',
                    AppColors.urgent,
                    tasks.where((t) => t.quadrant == EisenhowerQuadrant.delegate).toList(),
                  ),
                ),
                Expanded(
                  child: _buildQuadrant(
                    context,
                    'Not Important & Not Urgent',
                    AppColors.notUrgent,
                    tasks.where((t) => t.quadrant == EisenhowerQuadrant.delete).toList(),
                  ),
                ),
              ],
            ),
          ),
          // --- Calendar Integration Section ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!calendarProvider.isConnected)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => calendarProvider.connectAndFetch(),
                      icon: const Icon(Icons.calendar_month),
                      label: const Text('Integrate Google Calendar'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                
                if (calendarProvider.isLoading)
                  const Center(child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  )),

                if (calendarProvider.error != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      calendarProvider.error!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),

                if (calendarProvider.isConnected && !calendarProvider.isLoading) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        "Today's Agenda (",
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Product Sans', // Optional: if available, otherwise default
                          ),
                          children: const [
                            TextSpan(text: 'G', style: TextStyle(color: Color(0xFF4285F4))),
                            TextSpan(text: 'o', style: TextStyle(color: Color(0xFFDB4437))),
                            TextSpan(text: 'o', style: TextStyle(color: Color(0xFFF4B400))),
                            TextSpan(text: 'g', style: TextStyle(color: Color(0xFF4285F4))),
                            TextSpan(text: 'l', style: TextStyle(color: Color(0xFF0F9D58))),
                            TextSpan(text: 'e', style: TextStyle(color: Color(0xFFDB4437))),
                          ],
                        ),
                      ),
                      Text(
                        " Calendar)",
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (calendarProvider.events.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.event_busy, size: 16, color: Colors.grey),
                          SizedBox(width: 8),
                          Text("No tasks scheduled in Google Calendar today."),
                        ],
                      ),
                    )
                  else
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: calendarProvider.events.length,
                        itemBuilder: (context, index) {
                          return CalendarEventTile(event: calendarProvider.events[index]);
                        },
                      ),
                    ),
                  const Divider(height: 32),
                ],
              ],
            ),
          ),
          // --- End Calendar Section ---
          const SizedBox(height: 80), // Space for bottom nav
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AddTaskSheet(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildQuadrant(BuildContext context, String title, Color color, List<Task> tasks) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final quadrantColor = isDark ? color.withOpacity(0.2) : color.withOpacity(0.5);
    final cardColor = isDark ? Theme.of(context).cardTheme.color : Colors.white.withOpacity(0.8);
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: quadrantColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14, // Slightly smaller to fit longer titles
                color: textColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: tasks.isEmpty 
            ? Center(
                child: Text(
                  'No tasks',
                  style: TextStyle(
                    color: textColor?.withOpacity(0.5),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Card(
                  elevation: 0,
                  color: cardColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _showTaskDetails(context, task),
                    onLongPress: () => _confirmDelete(context, task),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 14, 
                            fontWeight: FontWeight.w600,
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                            color: task.isCompleted 
                                ? (isDark ? Colors.grey[600] : Colors.grey) 
                                : textColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          DateFormat('MMM d').format(task.dueDate),
                          style: TextStyle(fontSize: 12, color: textColor?.withOpacity(0.7)),
                        ),
                        trailing: Transform.scale(
                          scale: 0.8,
                          child: Checkbox(
                            value: task.isCompleted,
                            onChanged: (val) {
                              Provider.of<AppState>(context, listen: false)
                                  .toggleTaskCompletion(task.id);
                            },
                            shape: const CircleBorder(),
                            activeColor: AppColors.accentPrimary,
                            side: BorderSide(color: textColor ?? Colors.black54),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showTaskDetails(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.notes.isNotEmpty) ...[
              const Text('Notes:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(task.notes),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text('Due: ${DateFormat('MMM d, y - h:mm a').format(task.dueDate)}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.priority_high, 
                  size: 16, 
                  color: task.isImportant ? Colors.red : Colors.grey
                ),
                const SizedBox(width: 8),
                Text(task.isImportant ? 'Important' : 'Not Important'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time, 
                  size: 16, 
                  color: task.isUrgent ? Colors.orange : Colors.grey
                ),
                const SizedBox(width: 8),
                Text(task.isUrgent ? 'Urgent' : 'Not Urgent'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<AppState>(context, listen: false).deleteTask(task.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
