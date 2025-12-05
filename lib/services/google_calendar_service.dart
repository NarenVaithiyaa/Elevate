import 'package:googleapis/calendar/v3.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class GoogleCalendarService {
  final GoogleSignInAccount user;

  GoogleCalendarService(this.user);

  Future<List<Event>> getTodayEvents() async {
    try {
      // Get authenticated headers
      final headers = await user.authHeaders;
      
      // Create an authenticated client
      final client = GoogleAuthClient(headers);
      
      // Initialize Calendar API
      final calendar = CalendarApi(client);

      // Define time range for "Today"
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day).toUtc();
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59).toUtc();

      // Fetch events
      final events = await calendar.events.list(
        'primary',
        timeMin: startOfDay,
        timeMax: endOfDay,
        singleEvents: true,
        orderBy: 'startTime',
      );

      return events.items ?? [];
    } catch (e) {
      print('Error fetching calendar events: $e');
      rethrow;
    }
  }
}

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}
