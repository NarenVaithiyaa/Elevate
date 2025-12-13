import 'package:flutter/material.dart';
import 'package:habit_tracker_mvp/models/task.dart';
import 'package:habit_tracker_mvp/providers/app_state.dart';
import 'package:habit_tracker_mvp/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AddTaskSheet extends StatefulWidget {
  final Task? task;
  const AddTaskSheet({super.key, this.task});

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  late TextEditingController _titleController;
  late TextEditingController _notesController;
  DateTime _dueDate = DateTime.now();
  TimeOfDay _dueTime = TimeOfDay.now();
  bool _isImportant = false;
  bool _isUrgent = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _notesController = TextEditingController(text: widget.task?.notes ?? '');
    if (widget.task != null) {
      _dueDate = widget.task!.dueDate;
      _dueTime = TimeOfDay.fromDateTime(widget.task!.dueDate);
      _isImportant = widget.task!.isImportant;
      _isUrgent = widget.task!.isUrgent;
    }
  }


  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime,
    );
    if (picked != null) {
      setState(() => _dueTime = picked);
    }
  }

  void _submit() {
    if (_titleController.text.isEmpty) return;

    final dueDateTime = DateTime(
      _dueDate.year,
      _dueDate.month,
      _dueDate.day,
      _dueTime.hour,
      _dueTime.minute,
    );

    if (widget.task != null) {
      Provider.of<AppState>(context, listen: false).updateTask(
        widget.task!.id,
        _titleController.text,
        _notesController.text,
        dueDateTime,
        _isImportant,
        _isUrgent,
      );
    } else {
      Provider.of<AppState>(context, listen: false).addTask(
        _titleController.text,
        _notesController.text,
        dueDateTime,
        _isImportant,
        _isUrgent,
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            widget.task != null ? 'Edit Task' : 'New Task',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _titleController,
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
            decoration: InputDecoration(
              labelText: 'Title',
              labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.white.withOpacity(0.05) 
                  : AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
            decoration: InputDecoration(
              labelText: 'Notes',
              labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.white.withOpacity(0.05) 
                  : AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white.withOpacity(0.05) 
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, size: 20, 
                            color: Theme.of(context).textTheme.bodyMedium?.color),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('MMM d, y').format(_dueDate),
                          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: _pickTime,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white.withOpacity(0.05) 
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.access_time, size: 20, 
                            color: Theme.of(context).textTheme.bodyMedium?.color),
                        const SizedBox(width: 8),
                        Text(
                          _dueTime.format(context),
                          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: SwitchListTile(
                  title: const Text('Important', style: TextStyle(fontWeight: FontWeight.w600)),
                  value: _isImportant,
                  activeThumbColor: AppColors.accentPrimary,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) => setState(() => _isImportant = val),
                ),
              ),
              Expanded(
                child: SwitchListTile(
                  title: const Text('Urgent', style: TextStyle(fontWeight: FontWeight.w600)),
                  value: _isUrgent,
                  activeThumbColor: Colors.orange,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) => setState(() => _isUrgent = val),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                widget.task != null ? 'Save Changes' : 'Create Task',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 24),
        ],
      ),
    );
  }
}
