import 'package:flutter/material.dart';
import 'package:habit_tracker_mvp/providers/auth_provider.dart';
import 'package:habit_tracker_mvp/providers/app_state.dart';
import 'package:habit_tracker_mvp/providers/calendar_provider.dart';
import 'package:habit_tracker_mvp/services/notification_service.dart';
import 'package:habit_tracker_mvp/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // bool _notificationsEnabled = false; // Moved to AppState
  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    NotificationService().init();
  }

  Future<void> _scheduleNotifications() async {
    final appState = Provider.of<AppState>(context, listen: false);
    if (!appState.notificationsEnabled) return;

    final notificationService = NotificationService();
    await notificationService.cancelAllNotifications();

    // 1. Schedule Calendar Events
    final calendarProvider = Provider.of<CalendarProvider>(context, listen: false);
    if (calendarProvider.isConnected) {
      for (var event in calendarProvider.events) {
        if (event.start?.dateTime != null) {
          final startTime = event.start!.dateTime!;
          if (startTime.isAfter(DateTime.now())) {
             // Schedule at start time
             await notificationService.scheduleNotification(
               id: event.hashCode,
               title: 'Event Starting: ${event.summary ?? "No Title"}',
               body: 'Your event is starting now.',
               scheduledDate: startTime,
             );
             
             // Schedule 15 mins before
             final reminderTime = startTime.subtract(const Duration(minutes: 15));
             if (reminderTime.isAfter(DateTime.now())) {
               await notificationService.scheduleNotification(
                 id: event.hashCode + 1,
                 title: 'Upcoming Event: ${event.summary ?? "No Title"}',
                 body: 'Starts in 15 minutes.',
                 scheduledDate: reminderTime,
               );
             }
          }
        }
      }
    }

    // 2. Schedule Important & Urgent Tasks
    // final appState = Provider.of<AppState>(context, listen: false); // Already declared above
    final importantUrgentTasks = appState.tasks.where((t) => t.isImportant && t.isUrgent && !t.isCompleted).toList();
    
    for (var task in importantUrgentTasks) {
       final dueDate = task.dueDate;
       if (dueDate.isAfter(DateTime.now())) {
          await notificationService.scheduleNotification(
            id: task.hashCode,
            title: 'Urgent Task Due: ${task.title}',
            body: 'This task is marked as Important & Urgent.',
            scheduledDate: dueDate,
          );
       }
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext ctx) {
    final user = Provider.of<AuthProvider>(ctx).user;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.accentPrimary,
                backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                child: user?.photoURL == null 
                    ? Text(
                        user?.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(fontSize: 40, color: Colors.white),
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                user?.displayName ?? 'User Name',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                user?.email ?? 'email@example.com',
                style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              
              _buildSectionTitle(ctx, 'General'),
              _buildListTile(
                ctx,
                icon: Icons.fingerprint,
                title: 'Unlock with Fingerprint',
                trailing: Switch(
                  value: Provider.of<AppState>(ctx).biometricEnabled,
                  activeThumbColor: AppColors.accentPrimary,
                  onChanged: (val) async {
                    if (val) {
                      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
                      final bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();
                      
                      if (!canAuthenticate) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Biometrics not supported on this device')),
                          );
                        }
                        return;
                      }

                      try {
                        final bool didAuthenticate = await auth.authenticate(
                          localizedReason: 'Please authenticate to enable fingerprint unlock',
                          biometricOnly: true,
                        );
                        if (!didAuthenticate) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Authentication failed')),
                            );
                          }
                          return;
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                        return;
                      }
                    }
                    if (mounted) {
                      Provider.of<AppState>(context, listen: false).setBiometricEnabled(val);
                    }
                  },
                ),
              ),
              _buildListTile(
                ctx,
                icon: Icons.sync,
                title: 'Sync Calendars',
                trailing: Consumer<CalendarProvider>(
                  builder: (context, calendarProvider, child) {
                    return Switch(
                      value: calendarProvider.isConnected,
                      activeThumbColor: AppColors.accentPrimary,
                      onChanged: (val) async {
                        if (val) {
                          await calendarProvider.connectAndFetch();
                          final appState = Provider.of<AppState>(context, listen: false);
                          if (calendarProvider.isConnected && appState.notificationsEnabled) {
                            _scheduleNotifications();
                          }
                          if (mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(content: Text(calendarProvider.isConnected ? 'Calendar sync enabled' : 'Failed to sync calendar')),
                            );
                          }
                        } else {
                          calendarProvider.disconnect();
                          if (mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(content: Text('Calendar sync disabled')),
                            );
                          }
                        }
                      },
                    );
                  },
                ),
              ),
              _buildListTile(
                ctx,
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                trailing: Consumer<AppState>(
                  builder: (context, appState, child) {
                    return Switch(
                      value: appState.notificationsEnabled,
                      activeThumbColor: AppColors.accentPrimary,
                      onChanged: (val) async {
                        if (val) {
                          final granted = await NotificationService().requestPermissions();
                          if (granted) {
                            await appState.setNotificationsEnabled(true);
                            await _scheduleNotifications();
                            if (mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(content: Text('Notifications enabled')),
                              );
                            }
                          } else {
                            await appState.setNotificationsEnabled(false);
                            if (mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(content: Text('Permission denied')),
                              );
                            }
                          }
                        } else {
                          await appState.setNotificationsEnabled(false);
                          await NotificationService().cancelAllNotifications();
                          if (mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(content: Text('Notifications disabled')),
                            );
                          }
                        }
                      },
                    );
                  },
                ),
              ),
              _buildListTile(
                ctx,
                icon: Icons.dark_mode_outlined,
                title: 'Dark Mode',
                trailing: Switch(
                  value: Provider.of<AppState>(ctx).isDarkMode,
                  activeThumbColor: AppColors.accentPrimary,
                  onChanged: (val) {
                    Provider.of<AppState>(ctx, listen: false).toggleTheme();
                  },
                ),
              ),

              const SizedBox(height: 24),
              _buildSectionTitle(context, 'Account'),
              _buildListTile(
                context,
                icon: Icons.logout,
                title: 'Log Out',
                onTap: _handleLogout,
                textColor: Colors.red,
                iconColor: Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor ?? AppColors.accentPrimary),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: textColor ?? Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        trailing: trailing ?? const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}
