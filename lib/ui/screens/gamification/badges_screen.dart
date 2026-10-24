import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plantit/core/theme/app_colors.dart';
import 'package:plantit/ui/view_models/gamification_view_model.dart';
import 'package:plantit/ui/widgets/gamification_header.dart';

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gamificationVM = context.watch<GamificationViewModel>();
    final allBadges = gamificationVM.allBadges;
    final stats = gamificationVM.gamification;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trophies & Streaks 🏆🔥'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GamificationHeader(viewModel: gamificationVM),
            const SizedBox(height: 20),

            // Farming Statistics Grid
            const Text(
              'Your Urban Farming Milestones',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _StatMiniCard(
                    title: 'Current Streak',
                    value: '${stats.currentStreak} Days',
                    emoji: '🔥',
                    color: AppColors.streakOrange,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatMiniCard(
                    title: 'Best Streak',
                    value: '${stats.bestStreak} Days',
                    emoji: '⚡',
                    color: AppColors.sunYellow,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _StatMiniCard(
                    title: 'Plants Sown',
                    value: '${stats.totalPlantings}',
                    emoji: '🌱',
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatMiniCard(
                    title: 'Waterings',
                    value: '${stats.totalWaterings}',
                    emoji: '💧',
                    color: AppColors.waterBlue,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatMiniCard(
                    title: 'Harvests',
                    value: '${stats.totalHarvests}',
                    emoji: '🧺',
                    color: AppColors.terracotta,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Badge Showcase Gallery
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Badge Showcase',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  '${gamificationVM.unlockedBadges.length} / ${allBadges.length} Unlocked',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemCount: allBadges.length,
              itemBuilder: (context, index) {
                final badge = allBadges[index];
                final isUnlocked = badge.isUnlocked;

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUnlocked ? Colors.white : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isUnlocked ? AppColors.badgeGold : Colors.grey.shade300,
                      width: isUnlocked ? 2.0 : 1.0,
                    ),
                    boxShadow: [
                      if (isUnlocked)
                        BoxShadow(
                          color: AppColors.badgeGold.withAlpha(50),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: isUnlocked
                              ? AppColors.surfaceMuted
                              : Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          isUnlocked ? badge.emoji : '🔒',
                          style: TextStyle(
                            fontSize: 26,
                            color: isUnlocked ? null : Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        badge.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isUnlocked ? AppColors.textPrimary : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        badge.description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: isUnlocked ? AppColors.textSecondary : Colors.grey,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isUnlocked
                              ? AppColors.accent.withAlpha(40)
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '+${badge.bonusPoints} pts',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isUnlocked ? AppColors.primary : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _StatMiniCard extends StatelessWidget {
  final String title;
  final String value;
  final String emoji;
  final Color color;

  const _StatMiniCard({
    required this.title,
    required this.value,
    required this.emoji,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
