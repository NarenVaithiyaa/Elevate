import 'package:flutter/material.dart';
import 'package:habit_tracker_mvp/models/habit.dart';
import 'package:habit_tracker_mvp/providers/app_state.dart';
import 'package:habit_tracker_mvp/theme/app_theme.dart';
import 'package:provider/provider.dart';

class AddHabitSheet extends StatefulWidget {
  final Habit? habit;
  const AddHabitSheet({super.key, this.habit});

  @override
  State<AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends State<AddHabitSheet> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  String _frequency = 'Every day';
  Color _selectedColor = AppColors.cardYellow;
  IconData _selectedIcon = Icons.book;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.habit?.title ?? '');
    _descriptionController = TextEditingController(text: widget.habit?.description ?? '');
    if (widget.habit != null) {
      _selectedColor = widget.habit!.color;
      _selectedIcon = widget.habit!.icon;
      _frequency = widget.habit!.frequency == 'daily' ? 'Every day' : widget.habit!.frequency;
    }
  }


  final List<Color> _colors = [
    AppColors.cardYellow,
    AppColors.cardGreen,
    AppColors.cardBlue,
    AppColors.cardPink,
    AppColors.cardGray,
    const Color(0xFFFFCC80),
    const Color(0xFF80CBC4),
    const Color(0xFFCE93D8),
  ];

  final List<IconData> _icons = [
    Icons.book,
    Icons.home,
    Icons.computer,
    Icons.psychology,
    Icons.account_balance_wallet,
    Icons.fitness_center,
    Icons.water_drop,
    Icons.bed,
    Icons.music_note,
    Icons.brush,
    Icons.directions_run,
    Icons.restaurant,
    Icons.spa,
    Icons.work,
    Icons.school,
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_titleController.text.isEmpty) return;

    if (widget.habit != null) {
      Provider.of<AppState>(context, listen: false).updateHabit(
        widget.habit!.id,
        _titleController.text,
        _descriptionController.text,
        _selectedColor,
        _selectedIcon,
        _frequency,
      );
    } else {
      Provider.of<AppState>(context, listen: false).addHabit(
        _titleController.text,
        _descriptionController.text,
        _selectedColor,
        _selectedIcon,
        _frequency,
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
            widget.habit != null ? "Edit Habit" : "Let's start a new habit",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _titleController,
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
            decoration: InputDecoration(
              labelText: 'Name',
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
            controller: _descriptionController,
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
            decoration: InputDecoration(
              labelText: 'Description',
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
          DropdownButtonFormField<String>(
            initialValue: _frequency,
            dropdownColor: Theme.of(context).cardColor,
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
            decoration: InputDecoration(
              labelText: 'Intervals',
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
            items: ['Every day', 'Weekly', 'Custom']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _frequency = val);
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Icon & Color',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _colors.length,
              itemBuilder: (context, index) {
                final color = _colors[index];
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: _selectedColor == color
                          ? Border.all(
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black, 
                              width: 2
                            )
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _icons.length,
              itemBuilder: (context, index) {
                final icon = _icons[index];
                final isSelected = _selectedIcon == icon;
                final isDark = Theme.of(context).brightness == Brightness.dark;
                
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = icon),
                  child: Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.accentPrimary.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: AppColors.accentPrimary, width: 2)
                          : Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                    ),
                    child: Icon(
                      icon,
                      color: isSelected
                          ? AppColors.accentPrimary
                          : (isDark ? Colors.grey[400] : Colors.grey),
                    ),
                  ),
                );
              },
            ),
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
                widget.habit != null ? 'Save Changes' : 'Create Habit',
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
