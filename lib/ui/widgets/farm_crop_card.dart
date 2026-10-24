import 'package:flutter/material.dart';
import 'package:plantit/core/theme/app_colors.dart';
import 'package:plantit/data/models/farm_model.dart';

class FarmCropCard extends StatelessWidget {
  final FarmCrop crop;
  final VoidCallback onWater;
  final VoidCallback onHarvest;
  final VoidCallback onTap;

  const FarmCropCard({
    super.key,
    required this.crop,
    required this.onWater,
    required this.onHarvest,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isReadyToHarvest = crop.stage == GrowthStage.readyToHarvest;
    final bool isHarvested = crop.stage == GrowthStage.harvested;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: crop.needsWaterToday && !isHarvested
                ? AppColors.waterBlue.withAlpha(120)
                : Colors.grey.shade200,
            width: crop.needsWaterToday && !isHarvested ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Crop Emoji Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Text(crop.emoji, style: const TextStyle(fontSize: 26)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        crop.cropName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isHarvested
                                  ? Colors.grey.shade200
                                  : AppColors.primary.withAlpha(25),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              crop.stageTitle,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isHarvested ? Colors.grey : AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Day ${crop.daysSincePlanted}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Health Indicator Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: crop.healthScore >= 80
                        ? AppColors.primary.withAlpha(20)
                        : Colors.orange.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${crop.healthScore}% ❤️',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: crop.healthScore >= 80 ? AppColors.primary : Colors.orange.shade800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: crop.progressRatio,
                minHeight: 6,
                backgroundColor: Colors.grey.shade100,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isHarvested ? Colors.grey : AppColors.primaryLight,
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Bottom Action Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (crop.needsWaterToday && !isHarvested)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.waterBlue.withAlpha(20),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.water_drop, size: 12, color: AppColors.waterBlue),
                        SizedBox(width: 3),
                        Text(
                          'Water needed',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.waterBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Text(
                    isHarvested
                        ? 'Completed cycle'
                        : '${crop.totalGrowthDays - crop.daysSincePlanted} days to harvest',
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                Row(
                  children: [
                    if (!isHarvested && crop.needsWaterToday)
                      ElevatedButton.icon(
                        onPressed: onWater,
                        icon: const Icon(Icons.water_drop, size: 14),
                        label: const Text('Water (+2)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.waterBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          visualDensity: VisualDensity.compact,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    if (isReadyToHarvest) ...[
                      const SizedBox(width: 6),
                      ElevatedButton.icon(
                        onPressed: onHarvest,
                        icon: const Icon(Icons.shopping_basket, size: 14),
                        label: const Text('Harvest (+50)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.terracotta,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          visualDensity: VisualDensity.compact,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
