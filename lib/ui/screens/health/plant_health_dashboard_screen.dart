import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/farm_model.dart';
import '../../view_models/farm_view_model.dart';

class PlantHealthDashboardScreen extends StatelessWidget {
  const PlantHealthDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final farmVM = context.watch<FarmViewModel>();
    final crops = farmVM.activeCrops;
    final atRisk = crops.where((crop) => crop.healthScore < 80).toList();
    final average = crops.isEmpty ? 0 : (crops.fold<int>(0, (sum, crop) => sum + crop.healthScore) / crops.length).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Health & Recovery'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Garden health',
                  value: '$average%',
                  color: AppColors.primary,
                  icon: Icons.favorite_border,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  title: 'Recovery needed',
                  value: '${atRisk.length}',
                  color: AppColors.warning,
                  icon: Icons.healing,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recovery priority',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                if (atRisk.isEmpty)
                  const Text(
                    'Your garden is looking healthy. Keep watering in the morning and monitor for pests.',
                    style: TextStyle(color: AppColors.textSecondary),
                  )
                else
                  ...atRisk.take(3).map((crop) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: AppColors.warning,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${crop.cropName} • ${_statusLabel(crop)}',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      )),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (crops.isEmpty)
            _EmptyHealthState()
          else ...[
            const Text(
              'Crop health',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            ...crops.map((crop) => _PlantHealthCard(crop: crop)),
          ],
        ],
      ),
    );
  }
}

class _PlantHealthCard extends StatelessWidget {
  final FarmCrop crop;

  const _PlantHealthCard({required this.crop});

  @override
  Widget build(BuildContext context) {
    final farmVM = context.read<FarmViewModel>();
    final titleColor = crop.healthScore >= 85
        ? AppColors.primary
        : crop.healthScore >= 70
            ? AppColors.warning
            : AppColors.danger;

    final steps = _recoverySteps(crop);

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(crop.emoji, style: const TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      crop.cropName,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _statusLabel(crop),
                      style: TextStyle(
                        color: titleColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: titleColor.withAlpha(18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${crop.healthScore}%',
                  style: TextStyle(
                    color: titleColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LinearProgressIndicator(
            value: crop.healthScore / 100,
            minHeight: 8,
            borderRadius: BorderRadius.circular(999),
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(titleColor),
          ),
          const SizedBox(height: 12),
          const Text(
            'Recovery recommendations',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          const SizedBox(height: 8),
          ...steps.map((step) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontWeight: FontWeight.w700)),
                    Expanded(
                      child: Text(
                        step,
                        style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await farmVM.logCare(crop.id, ActivityType.water, notes: 'Recovery watering check');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Water reminder logged for ${crop.cropName}')),
                      );
                    }
                  },
                  icon: const Icon(Icons.water_drop_outlined, size: 16),
                  label: const Text('Water'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await farmVM.logCare(crop.id, ActivityType.prune, notes: 'Pruned damaged leaves');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Pruning step logged for ${crop.cropName}')),
                      );
                    }
                  },
                  icon: const Icon(Icons.content_cut, size: 16),
                  label: const Text('Prune'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHealthState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Text('🌿', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 10),
          const Text(
            'No crops yet',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your first crop to begin health tracking and recovery recommendations.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

String _statusLabel(FarmCrop crop) {
  if (crop.healthScore >= 85) return 'Healthy and growing strongly';
  if (crop.healthScore >= 70) return 'Needs close monitoring';
  return 'Recovery needed';
}

List<String> _recoverySteps(FarmCrop crop) {
  final steps = <String>[];

  if (crop.needsWaterToday) {
    steps.add('Water in the early morning and check the soil before the next cycle.');
  } else {
    steps.add('Soil looks stable. Keep watering only when the top layer feels dry.');
  }

  if (crop.healthScore < 80) {
    steps.add('Remove any yellow or wilted leaves to reduce stress and improve airflow.');
  } else {
    steps.add('Keep the leaves dry at night and maintain good airflow around the plant.');
  }

  if (crop.healthScore < 70) {
    steps.add('Reduce stress by checking drainage, sunlight, and pest damage before the next watering cycle.');
  } else {
    steps.add('Continue with regular checks and keep the plant in bright, gentle light.');
  }

  return steps;
}
