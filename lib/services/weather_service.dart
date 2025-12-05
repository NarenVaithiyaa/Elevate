import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  // TODO: Replace with your OpenWeatherMap API key
  static const String _apiKey = 'YOUR_OPENWEATHERMAP_API_KEY';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<Map<String, dynamic>> getWeather() async {
    try {
      final position = await _determinePosition();
      final url = '$_baseUrl?lat=${position.latitude}&lon=${position.longitude}&appid=$_apiKey&units=metric';
      
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        // Fallback or error
        print('Failed to load weather: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      print('Error getting weather: $e');
      return {};
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
