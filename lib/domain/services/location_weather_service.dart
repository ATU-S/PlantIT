import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class WeatherData {
  final double temperatureCelsius;
  final double humidity;
  final double precipitationMm;
  final double uvIndex;
  final String conditionLabel;
  final String conditionEmoji;
  final String agriAdvice;
  final String locationLabel;

  const WeatherData({
    required this.temperatureCelsius,
    required this.humidity,
    required this.precipitationMm,
    required this.uvIndex,
    required this.conditionLabel,
    required this.conditionEmoji,
    required this.agriAdvice,
    required this.locationLabel,
  });
}

class LocationWeatherService extends ChangeNotifier {
  WeatherData? _current;
  bool _loading = false;
  String _error = '';
  String _selectedDistrict = 'Ernakulam';
  bool _locating = false;
  String _locationStatus = '';

  WeatherData? get current => _current;
  bool get loading => _loading;
  String get error => _error;
  String get selectedDistrict => _selectedDistrict;
  bool get locating => _locating;
  String get locationStatus => _locationStatus;

  // Kerala district lat/lon lookup – intentionally public for UI district picker
  static const Map<String, List<double>> districtCoords = {
    'Thiruvananthapuram': [8.5241, 76.9366],
    'Kollam': [8.8932, 76.6141],
    'Pathanamthitta': [9.2648, 76.7870],
    'Alappuzha': [9.4981, 76.3388],
    'Kottayam': [9.5916, 76.5222],
    'Idukki': [9.9189, 77.1025],
    'Ernakulam': [9.9816, 76.2999],
    'Thrissur': [10.5276, 76.2144],
    'Palakkad': [10.7867, 76.6548],
    'Malappuram': [11.0511, 76.0711],
    'Kozhikode': [11.2588, 75.7804],
    'Wayanad': [11.6854, 76.1320],
    'Kannur': [11.8745, 75.3704],
    'Kasaragod': [12.4996, 74.9869],
  };

  /// Requests foreground location once and selects the nearest Kerala
  /// district. The weather card can still be changed manually if permission
  /// is denied or the user is outside Kerala.
  Future<void> detectUserLocation() async {
    if (_locating) return;

    _locating = true;
    _locationStatus = 'Detecting your location…';
    notifyListeners();

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw const LocationServiceDisabledException();
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw StateError('Location permission unavailable');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 12),
        ),
      );
      final district = nearestDistrict(position.latitude, position.longitude);
      _locating = false;
      notifyListeners();
      await fetchWeatherForDistrict(district);
      _locationStatus = 'Using your location: $district, Kerala';
      notifyListeners();
    } catch (_) {
      _locating = false;
      _locationStatus =
          'Location unavailable. Using $_selectedDistrict; choose a district manually if needed.';
      notifyListeners();
      await fetchWeatherForDistrict(_selectedDistrict);
    }
  }

  /// Finds the closest known Kerala district using the local district map.
  static String nearestDistrict(double latitude, double longitude) {
    var closestDistrict = districtCoords.keys.first;
    var closestDistance = double.infinity;

    for (final entry in districtCoords.entries) {
      final latitudeDelta = latitude - entry.value[0];
      final longitudeDelta = longitude - entry.value[1];
      final distance =
          latitudeDelta * latitudeDelta + longitudeDelta * longitudeDelta;
      if (distance < closestDistance) {
        closestDistance = distance;
        closestDistrict = entry.key;
      }
    }
    return closestDistrict;
  }

  Future<void> fetchWeatherForDistrict(String district) async {
    _selectedDistrict = district;
    _locationStatus = 'Using $district, Kerala';
    _loading = true;
    _error = '';
    notifyListeners();

    final coords = districtCoords[district] ?? districtCoords['Ernakulam']!;
    final lat = coords[0];
    final lon = coords[1];

    try {
      // Open-Meteo: free, no key required, very reliable for India
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=$lat&longitude=$lon'
        '&current=temperature_2m,relative_humidity_2m,precipitation,uv_index,weather_code'
        '&timezone=Asia/Kolkata'
        '&forecast_days=1',
      );
      final resp = await http.get(url).timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final cur = data['current'] as Map<String, dynamic>;
        final temp = (cur['temperature_2m'] as num).toDouble();
        final humidity = (cur['relative_humidity_2m'] as num).toDouble();
        final precip = (cur['precipitation'] as num).toDouble();
        final uv = (cur['uv_index'] as num).toDouble();
        final wCode = cur['weather_code'] as int;

        final (emoji, label) = _weatherCodeToLabel(wCode);
        final advice = _generateAgriAdvice(
          temp,
          humidity,
          precip,
          uv,
          district,
        );

        _current = WeatherData(
          temperatureCelsius: temp,
          humidity: humidity,
          precipitationMm: precip,
          uvIndex: uv,
          conditionLabel: label,
          conditionEmoji: emoji,
          agriAdvice: advice,
          locationLabel: '$district, Kerala',
        );
        _error = '';
      } else {
        _current = _offlineDefault(district);
        _error = 'Using cached estimate (no network)';
      }
    } catch (e) {
      _current = _offlineDefault(district);
      _error = 'Using cached estimate (no network)';
    }

    _loading = false;
    notifyListeners();
  }

  WeatherData _offlineDefault(String district) {
    // Intelligent offline seasonal estimates for Kerala
    final month = DateTime.now().month;
    double temp;
    double humidity;
    double precip;
    String emoji;
    String label;

    if (month >= 6 && month <= 9) {
      temp = 26.5;
      humidity = 92;
      precip = 18.0;
      emoji = '🌧️';
      label = 'Southwest Monsoon';
    } else if (month >= 10 && month <= 11) {
      temp = 27.0;
      humidity = 85;
      precip = 8.0;
      emoji = '⛅';
      label = 'Northeast Monsoon';
    } else if (month >= 12 || month <= 2) {
      temp = 25.0;
      humidity = 75;
      precip = 1.0;
      emoji = '☀️';
      label = 'Clear & Cool';
    } else {
      temp = 32.0;
      humidity = 70;
      precip = 0.5;
      emoji = '🌤️';
      label = 'Hot Summer';
    }

    return WeatherData(
      temperatureCelsius: temp,
      humidity: humidity,
      precipitationMm: precip,
      uvIndex: 7.0,
      conditionLabel: label,
      conditionEmoji: emoji,
      agriAdvice: _generateAgriAdvice(temp, humidity, precip, 7.0, district),
      locationLabel: '$district, Kerala',
    );
  }

  (String, String) _weatherCodeToLabel(int code) {
    if (code == 0) return ('☀️', 'Clear Sky');
    if (code <= 2) return ('🌤️', 'Partly Cloudy');
    if (code <= 3) return ('☁️', 'Overcast');
    if (code <= 50) return ('🌫️', 'Foggy');
    if (code <= 67) return ('🌧️', 'Rainy');
    if (code <= 77) return ('🌨️', 'Snow / Hail');
    if (code <= 82) return ('🌦️', 'Rain Showers');
    return ('⛈️', 'Thunderstorm');
  }

  String _generateAgriAdvice(
    double temp,
    double humidity,
    double precip,
    double uv,
    String district,
  ) {
    if (precip > 10) {
      return '⚠️ Heavy rainfall today. Ensure grow bags have drainage; avoid fertilizing. Check for root rot.';
    }
    if (precip > 2) {
      return '🌧️ Light rain today. Skip watering; ideal to transplant seedlings or apply organic compost.';
    }
    if (temp > 35) {
      return '🔥 Extreme heat ($temp°C). Water plants at 7 AM and 5 PM. Use shade net (50%) for sensitive crops.';
    }
    if (humidity > 90) {
      return '💧 Very high humidity. Watch for powdery mildew and fungal leaf spots. Improve airflow around plants.';
    }
    if (uv > 9) {
      return '☀️ High UV today. Great for flowering plants! Protect seedlings and newly transplanted saplings.';
    }
    return '🌿 Good growing day for $district. Ideal for planting, watering, and foliar sprays.';
  }
}
