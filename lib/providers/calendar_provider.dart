import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:habit_tracker_mvp/services/auth_service.dart';
import 'package:habit_tracker_mvp/services/google_calendar_service.dart';

class CalendarProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  List<Event> _events = [];
  List<Event> get events => _events;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  String? _error;
  String? get error => _error;

  CalendarProvider() {
    _authService.authStateChanges.listen((user) {
      if (user == null) {
        _events = [];
        _isConnected = false;
        _error = null;
        notifyListeners();
      } else {
        _restoreConnection();
      }
    });
  }

  Future<void> _restoreConnection() async {
    // Attempt to restore connection silently
    final canRestore = await _authService.trySilentSignIn();
    if (canRestore) {
      // If silent sign-in works, try to fetch. 
      // We use a modified flow that doesn't force interactive sign-in.
      await connectAndFetch(silent: true);
    }
  }

  Future<void> connectAndFetch({bool silent = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Request Permission (or check if already granted)
      // If silent is true, we assume trySilentSignIn was called or we don't want UI.
      // But requestCalendarPermission in AuthService might trigger UI if not signed in.
      // We should probably modify requestCalendarPermission or handle it here.
      
      // Actually, if we are here, we want to fetch.
      // If silent=true, we rely on the fact that we just did trySilentSignIn.
      
      final granted = await _authService.requestCalendarPermission();
      if (!granted) {
        if (!silent) _error = "Calendar permission denied.";
        _isLoading = false;
        notifyListeners();
        return;
      }

      // 2. Get Current Google User
      final googleUser = _authService.currentGoogleUser;
      if (googleUser == null) {
        if (!silent) _error = "No Google user found. Please sign in again.";
        _isLoading = false;
        notifyListeners();
        return;
      }

      // 3. Fetch Events
      final service = GoogleCalendarService(googleUser);
      _events = await service.getTodayEvents();
      _isConnected = true;
      
    } catch (e) {
      if (!silent) _error = "Failed to load calendar: $e";
      _isConnected = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
