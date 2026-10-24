import 'package:flutter_test/flutter_test.dart';
import 'package:plantit/domain/services/location_weather_service.dart';

void main() {
  test('maps a GPS position to the nearest Kerala district', () {
    expect(
      LocationWeatherService.nearestDistrict(9.9816, 76.2999),
      'Ernakulam',
    );
    expect(
      LocationWeatherService.nearestDistrict(11.2588, 75.7804),
      'Kozhikode',
    );
  });
}
