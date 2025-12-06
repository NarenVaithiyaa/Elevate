import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  // TODO: Replace with your OpenWeatherMap API key
  static const String _apiKey = 'f2b6ff4519dd23e52ddeb2c26e66d2ec';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the 
      // App to enable the location services.
      print('Location services are disabled. Using default location.');
      return Position(
        longitude: -0.1278,
        latitude: 51.5074,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0, 
        altitudeAccuracy: 0, 
        headingAccuracy: 0
      );
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied. Using default location.');
        return Position(
          longitude: -0.1278,
          latitude: 51.5074,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0, 
          altitudeAccuracy: 0, 
          headingAccuracy: 0
        );
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      print('Location permissions are permanently denied. Using default location.');
      return Position(
        longitude: -0.1278,
        latitude: 51.5074,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0, 
        altitudeAccuracy: 0, 
        headingAccuracy: 0
      );
    } 

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    // Add a timeout to prevent hanging
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          timeLimit: Duration(seconds: 5),
        ),
      );
    } catch (e) {
      print('Error getting location: $e. Using default location.');
      return Position(
        longitude: -0.1278,
        latitude: 51.5074,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0, 
        altitudeAccuracy: 0, 
        headingAccuracy: 0
      );
    }
  }

  Future<Map<String, dynamic>> getWeather() async {
    try {
      final position = await _determinePosition();
      final url = '$_baseUrl?lat=${position.latitude}&lon=${position.longitude}&appid=$_apiKey&units=metric';
      
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        // Fallback for invalid API key (demo mode)
        print('Invalid API key. Using mock data.');
        return {
          'weather': [
            {'main': 'Clear', 'description': 'clear sky'}
          ],
          'main': {'temp': 22.5}
        };
      } else {
        // Fallback or error
        print('Failed to load weather: ${response.statusCode} ${response.body}');
        throw Exception('Failed to load weather: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting weather: $e');
      rethrow;
    }
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning,';
    } else if (hour < 17) {
      return 'Good afternoon,';
    } else {
      return 'Good evening,';
    }
  }

  String getWeatherSuggestion(String mainCondition, double temp) {
    // Simple logic based on main condition
    switch (mainCondition.toLowerCase()) {
      case 'thunderstorm':
        return 'Stay safe indoors! Perfect time for deep work.';
      case 'drizzle':
      case 'rain':
        return 'It\'s raining. Maybe a good book or indoor workout?';
      case 'snow':
        return 'Snowy day! Stay warm and cozy.';
      case 'clear':
        return 'Clear skies! Great for a walk or outdoor activity.';
      case 'clouds':
        return 'It\'s cloudy. Good for focused tasks.';
      default:
        if (temp > 30) {
          return 'It\'s hot outside. Stay hydrated!';
        } else if (temp < 10) {
          return 'Chilly weather. Bundle up!';
        }
        return 'Have a productive day!';
    }
  }
}
