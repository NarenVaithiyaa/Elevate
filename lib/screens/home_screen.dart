import 'package:flutter/material.dart';
import 'package:habit_tracker_mvp/providers/auth_provider.dart';
import 'package:habit_tracker_mvp/providers/app_state.dart';
import 'package:habit_tracker_mvp/screens/add_habit_sheet.dart';
import 'package:habit_tracker_mvp/screens/add_task_sheet.dart';
import 'package:habit_tracker_mvp/screens/manage_habits_screen.dart';
import 'package:habit_tracker_mvp/screens/monthly_progress_screen.dart';
import 'package:habit_tracker_mvp/screens/profile_screen.dart';
import 'package:habit_tracker_mvp/screens/task_matrix_screen.dart';
import 'package:habit_tracker_mvp/theme/app_theme.dart';
import 'package:habit_tracker_mvp/widgets/bottom_nav_bar.dart';
import 'package:habit_tracker_mvp/widgets/habit_card.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker_mvp/services/weather_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardView(onCalendarTap: () => _onTabTapped(2)),
      const TaskMatrixScreen(),
      const MonthlyProgressScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Listen to AuthProvider so we get notified when user is set
    final user = Provider.of<AuthProvider>(context).user;
    if (user != null) {
      Provider.of<AppState>(context, listen: false).initialize(user.uid);
    }
  }

  void _onTabTapped(int index) {
    if (index == 4) {
      _showAddOptions(context);
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.loop, color: AppColors.accentPrimary),
              title: const Text('New Habit'),
              onTap: () {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const AddHabitSheet(),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle_outline, color: AppColors.accentPrimary),
              title: const Text('New Task'),
              onTap: () {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const AddTaskSheet(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

class DashboardView extends StatefulWidget {
  final VoidCallback onCalendarTap;

  const DashboardView({super.key, required this.onCalendarTap});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final WeatherService _weatherService = WeatherService();
  String _greeting = 'Good morning,';
  String _weatherCondition = 'Loading...';
  String _weatherSuggestion = 'Fetching weather...';
  IconData _weatherIcon = Icons.cloud;

  @override
  void initState() {
    super.initState();
    _updateGreeting();
    _fetchWeather();
  }

  void _updateGreeting() {
    setState(() {
      _greeting = _weatherService.getGreeting();
    });
  }

  Future<void> _fetchWeather() async {
    try {
      final weatherData = await _weatherService.getWeather();
      if (weatherData.isNotEmpty) {
        final main = weatherData['weather'][0]['main'];
        final temp = weatherData['main']['temp'];
        
        if (mounted) {
          setState(() {
            _weatherCondition = "It's $main!";
            _weatherSuggestion = _weatherService.getWeatherSuggestion(main, temp.toDouble());
            _weatherIcon = _getWeatherIcon(main);
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _weatherCondition = "Weather unavailable";
            _weatherSuggestion = "Could not fetch local weather.";
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _weatherCondition = "Weather unavailable";
          _weatherSuggestion = "Please check location permissions.";
        });
      }
    }
  }

  IconData _getWeatherIcon(String main) {
    switch (main.toLowerCase()) {
      case 'thunderstorm': return Icons.flash_on;
      case 'drizzle':
      case 'rain': return Icons.grain;
      case 'snow': return Icons.ac_unit;
      case 'clear': return Icons.wb_sunny;
      case 'clouds': return Icons.cloud;
      default: return Icons.wb_cloudy;
    }
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: Colors.green),
              ),
              title: const Text('Great job!'),
              subtitle: const Text('You completed all habits yesterday.'),
              trailing: Text('2h ago', style: Theme.of(context).textTheme.bodySmall),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.schedule, color: Colors.orange),
              ),
              title: const Text('Reminder'),
              subtitle: const Text('Time to read for 15 mins'),
              trailing: Text('5h ago', style: Theme.of(context).textTheme.bodySmall),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      user?.displayName?.split(' ')[0] ?? 'User',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.calendar_today_outlined),
                      onPressed: widget.onCalendarTap,
                    ),
                    Stack(
                      children: [
                        if (user?.photoURL != null)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              radius: 16,
                              backgroundImage: NetworkImage(user!.photoURL!),
                            ),
                          )
                        else
                          IconButton(
                            icon: const Icon(Icons.notifications_none_outlined),
                            onPressed: () => _showNotifications(context),
                          ),
                        if (user?.photoURL == null)
                          Positioned(
                            right: 12,
                            top: 12,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Week Strip
            const WeekStrip(),
            const SizedBox(height: 24),

            // Recommendation Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2D3748) : const Color(0xFFD9E8FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.1) : Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_weatherIcon, color: AppColors.accentPrimary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _weatherCondition,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        Text(
                          _weatherSuggestion,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.grey[300] : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Habit Cards Grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Habits',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ManageHabitsScreen()),
                    );
                  },
                  child: const Text('Manage Habits'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: appState.habits.length,
              itemBuilder: (context, index) {
                return HabitCard(habit: appState.habits[index]);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class WeekStrip extends StatelessWidget {
  const WeekStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final today = DateTime.now().weekday - 1; // 0-6
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;
    final unselectedColor = isDark ? Colors.grey[500] : AppColors.textSecondary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final isSelected = index == today;
        return Column(
          children: [
            Text(
              days[index],
              style: TextStyle(
                color: isSelected ? textColor : unselectedColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected 
                    ? (isDark ? Colors.white : Colors.black) 
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${DateTime.now().subtract(Duration(days: today - index)).day}',
                style: TextStyle(
                  color: isSelected 
                      ? (isDark ? Colors.black : Colors.white) 
                      : textColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
