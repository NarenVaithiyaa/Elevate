import 'package:flutter/material.dart';
import 'package:habit_tracker_mvp/providers/app_state.dart';
import 'package:habit_tracker_mvp/theme/app_theme.dart';
import 'package:provider/provider.dart';

class MonthlyProgressScreen extends StatefulWidget {
  const MonthlyProgressScreen({super.key});

  @override
  State<MonthlyProgressScreen> createState() => _MonthlyProgressScreenState();
}

class _MonthlyProgressScreenState extends State<MonthlyProgressScreen> {
  DateTime _focusedDate = DateTime.now();

  void _changeMonth(int offset) {
    setState(() {
      _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + offset);
    });
  }

  int _getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  int _getFirstWeekday(DateTime date) {
    return DateTime(date.year, date.month, 1).weekday;
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final habits = appState.habits;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate completion data for the focused month
    final Map<int, int> dailyCompletions = {};
    for (var habit in habits) {
      for (var date in habit.completedDates) {
        if (date.year == _focusedDate.year && date.month == _focusedDate.month) {
          dailyCompletions[date.day] = (dailyCompletions[date.day] ?? 0) + 1;
        }
      }
    }

    final daysInMonth = _getDaysInMonth(_focusedDate);
    final firstWeekday = _getFirstWeekday(_focusedDate); // 1 = Mon, 7 = Sun
    // Adjust for 0-based index if needed, but GridView usually works well with 1-based logic if we pad.
    // Let's assume Monday start.
    final paddingDays = firstWeekday - 1; 

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Progress'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Cards (Placeholder for now, or we can calculate)
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Total Habits',
                    '${habits.length}',
                    Icons.list,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'This Month',
                    '${dailyCompletions.values.fold(0, (a, b) => a + b)} done',
                    Icons.check_circle,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Heatmap Calendar
            Text(
              'Consistency Map',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color ?? (isDark ? const Color(0xFF1E1E1E) : Colors.white),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () => _changeMonth(-1),
                      ),
                      Text(
                        '${_monthName(_focusedDate.month)} ${_focusedDate.year}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () => _changeMonth(1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Weekday headers
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                        .map((day) => SizedBox(
                              width: 32,
                              child: Text(
                                day,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: daysInMonth + paddingDays,
                    itemBuilder: (context, index) {
                      if (index < paddingDays) {
                        return const SizedBox();
                      }
                      
                      final day = index - paddingDays + 1;
                      final count = dailyCompletions[day] ?? 0;
                      final totalHabits = habits.length;
                      final intensity = totalHabits == 0 ? 0.0 : (count / totalHabits).clamp(0.0, 1.0);
                      
                      // Color logic
                      Color cellColor;
                      if (count == 0) {
                        cellColor = isDark ? Colors.grey[800]! : Colors.grey[200]!;
                      } else {
                        cellColor = AppColors.accentPrimary.withOpacity(0.2 + (0.8 * intensity));
                      }

                      return Container(
                        decoration: BoxDecoration(
                          color: cellColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$day',
                          style: TextStyle(
                            color: count > 0 
                                ? (intensity > 0.5 ? Colors.white : AppColors.accentPrimary)
                                : (isDark ? Colors.grey[600] : Colors.grey[400]),
                            fontWeight: count > 0 ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }


  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.grey[400] : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
