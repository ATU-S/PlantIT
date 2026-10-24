import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plantit/core/theme/app_colors.dart';
import 'package:plantit/data/models/farm_model.dart';
import 'package:plantit/data/models/gamification_model.dart';
import 'package:plantit/ui/view_models/farm_view_model.dart';
import 'package:plantit/ui/view_models/gamification_view_model.dart';
import 'package:plantit/ui/widgets/gamification_header.dart';
import 'package:plantit/ui/widgets/weather_kerala_card.dart';
import 'package:plantit/ui/widgets/farm_crop_card.dart';
import 'package:plantit/ui/widgets/badge_unlock_dialog.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback onNavigateToPlanner;
  final VoidCallback onNavigateToGarden;
  final VoidCallback onNavigateToBadges;

  const DashboardScreen({
    super.key,
    required this.onNavigateToPlanner,
    required this.onNavigateToGarden,
    required this.onNavigateToBadges,
  });

  void _handleBadgeRewards(BuildContext context, List<PlantBadge> newlyUnlocked) {
    for (final badge in newlyUnlocked) {
      BadgeUnlockDialog.show(context, badge);
    }
  }

  @override
  Widget build(BuildContext context) {
    final farmVM = context.watch<FarmViewModel>();
    final gamificationVM = context.watch<GamificationViewModel>();
    final activeFarm = farmVM.activeFarm;
    final cropsNeedingCare = farmVM.cropsNeedingCare;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('🌱', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Text(
              activeFarm?.name ?? 'PlantIT Farm',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: AppColors.primary),
            tooltip: 'AI Farm Planner',
            onPressed: onNavigateToPlanner,
          ),
          IconButton(
            icon: const Icon(Icons.emoji_events_outlined, color: AppColors.streakOrange),
            tooltip: 'Badges & Streaks',
            onPressed: onNavigateToBadges,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => farmVM.refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Gamification Hero
              GamificationHeader(
                viewModel: gamificationVM,
                onBadgesTap: onNavigateToBadges,
              ),
              const SizedBox(height: 16),

              // 2. Kerala Agro Weather
              const WeatherKeralaCard(),
              const SizedBox(height: 18),

              // 3. Quick Action Care Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _QuickCareButton(
                      icon: Icons.water_drop,
                      color: AppColors.waterBlue,
                      label: 'Water All',
                      subtitle: '+2 pts each',
                      onTap: () async {
                        if (cropsNeedingCare.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('All plants are already well-hydrated today! 💧')),
                          );
                          return;
                        }
                        final badges = await farmVM.waterAllPending();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.primary,
                              content: Text('Watered ${cropsNeedingCare.length} plants! Points earned! 🪴'),
                            ),
                          );
                          _handleBadgeRewards(context, badges);
                        }
                      },
                    ),
                    Container(height: 36, width: 1, color: Colors.grey.shade300),
                    _QuickCareButton(
                      icon: Icons.add_circle_outline,
                      color: AppColors.primary,
                      label: 'New Crop',
                      subtitle: '+10 pts',
                      onTap: onNavigateToPlanner,
                    ),
                    Container(height: 36, width: 1, color: Colors.grey.shade300),
                    _QuickCareButton(
                      icon: Icons.shopping_basket_outlined,
                      color: AppColors.terracotta,
                      label: 'My Garden',
                      subtitle: '${farmVM.activeCrops.length} planted',
                      onTap: onNavigateToGarden,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // 4. Urgent Tasks Alert
              if (cropsNeedingCare.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.notifications_active, color: AppColors.waterBlue, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          'Daily Care Due (${cropsNeedingCare.length})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () async {
                        final badges = await farmVM.waterAllPending();
                        if (context.mounted) _handleBadgeRewards(context, badges);
                      },
                      child: const Text('Water All Now', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...cropsNeedingCare.map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: FarmCropCard(
                        crop: c,
                        onWater: () async {
                          final badges = await farmVM.waterCrop(c.id);
                          if (context.mounted) _handleBadgeRewards(context, badges);
                        },
                        onHarvest: () async {
                          final badges = await farmVM.harvestCrop(c.id);
                          if (context.mounted) _handleBadgeRewards(context, badges);
                        },
                        onTap: onNavigateToGarden,
                      ),
                    )),
                const SizedBox(height: 14),
              ],

              // 5. Active Growing Garden Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Active Garden Crops',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: onNavigateToGarden,
                    child: const Text('View All', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (farmVM.activeCrops.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text('🌱', style: TextStyle(fontSize: 40)),
                      const SizedBox(height: 10),
                      const Text(
                        'Your garden is waiting for its first crop!',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Use our AI Farm Planner to analyze your balcony or terrace sunlight.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton.icon(
                        onPressed: onNavigateToPlanner,
                        icon: const Icon(Icons.camera_alt_outlined),
                        label: const Text('Plan with AI'),
                      ),
                    ],
                  ),
                )
              else
                ...farmVM.activeCrops.take(4).map(
                      (c) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: FarmCropCard(
                          crop: c,
                          onWater: () async {
                            final badges = await farmVM.waterCrop(c.id);
                            if (context.mounted) _handleBadgeRewards(context, badges);
                          },
                          onHarvest: () async {
                            final badges = await farmVM.harvestCrop(c.id);
                            if (context.mounted) _handleBadgeRewards(context, badges);
                          },
                          onTap: onNavigateToGarden,
                        ),
                      ),
                    ),

              const SizedBox(height: 16),

              // 6. Recent Care Activity Feed
              if (farmVM.recentActivities.isNotEmpty) ...[
                const Text(
                  'Recent Garden Log',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: farmVM.recentActivities.take(3).length,
                    separatorBuilder: (_, _) => Divider(height: 1, color: Colors.grey.shade100),
                    itemBuilder: (context, index) {
                      final act = farmVM.recentActivities[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.surfaceMuted,
                          child: Icon(
                            act.type == ActivityType.water
                                ? Icons.water_drop
                                : act.type == ActivityType.harvest
                                    ? Icons.shopping_basket
                                    : Icons.spa,
                            color: AppColors.primary,
                            size: 18,
                          ),
                        ),
                        title: Text(
                          '${act.type.name.toUpperCase()}: ${act.cropName}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        subtitle: Text(
                          act.notes.isNotEmpty ? act.notes : 'Logged on ${act.timestamp.day}/${act.timestamp.month}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withAlpha(30),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '+${act.pointsEarned} pts',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickCareButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickCareButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
