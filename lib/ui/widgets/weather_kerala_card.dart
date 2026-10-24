import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/services/location_weather_service.dart';

class WeatherKeralaCard extends StatefulWidget {
  const WeatherKeralaCard({super.key});

  @override
  State<WeatherKeralaCard> createState() => _WeatherKeralaCardState();
}

class _WeatherKeralaCardState extends State<WeatherKeralaCard> {
  @override
  void initState() {
    super.initState();
    // Auto-fetch on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final service = context.read<LocationWeatherService>();
      if (service.current == null && !service.loading && !service.locating) {
        service.detectUserLocation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<LocationWeatherService>();
    final weather = service.current;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withAlpha(20), const Color(0xFFE3F2FD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                weather?.conditionEmoji ?? '⛅',
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kerala Agro Weather',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      weather?.locationLabel ??
                          '${service.selectedDistrict}, Kerala',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Location district picker
              GestureDetector(
                onTap: () => _showDistrictPicker(context, service),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primary.withAlpha(40)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 13,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        service.selectedDistrict.split(' ').first, // Shortened
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_drop_down,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // Refresh button
              GestureDetector(
                onTap: service.loading
                    ? null
                    : () => service.fetchWeatherForDistrict(
                        service.selectedDistrict,
                      ),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(15),
                    shape: BoxShape.circle,
                  ),
                  child: service.loading
                      ? const Padding(
                          padding: EdgeInsets.all(7),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      : const Icon(
                          Icons.refresh,
                          size: 18,
                          color: AppColors.primary,
                        ),
                ),
              ),
            ],
          ),

          if (service.locationStatus.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              service.locationStatus,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],

          if (weather != null) ...[
            const SizedBox(height: 14),
            // Stat pills row
            Row(
              children: [
                _StatPill(
                  emoji: '🌡️',
                  value: '${weather.temperatureCelsius.toStringAsFixed(1)}°C',
                  label: 'Temp',
                ),
                _StatPill(
                  emoji: '💧',
                  value: '${weather.humidity.toStringAsFixed(0)}%',
                  label: 'Humidity',
                ),
                _StatPill(
                  emoji: '🌧️',
                  value: '${weather.precipitationMm.toStringAsFixed(1)}mm',
                  label: 'Rain',
                ),
                _StatPill(
                  emoji: '☀️',
                  value: weather.uvIndex.toStringAsFixed(0),
                  label: 'UV',
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Agri advice banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(190),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                weather.agriAdvice,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],

          if (service.error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                service.error,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showDistrictPicker(
    BuildContext context,
    LocationWeatherService service,
  ) {
    final districts = LocationWeatherService.districtCoords.keys.toList()
      ..sort();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Select Your District',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ...districts.map(
            (d) => ListTile(
              leading: const Icon(Icons.location_on, color: AppColors.primary),
              title: Text(d),
              selected: d == service.selectedDistrict,
              selectedTileColor: AppColors.primary.withAlpha(15),
              onTap: () {
                Navigator.pop(context);
                service.fetchWeatherForDistrict(d);
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;

  const _StatPill({
    required this.emoji,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 3),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
