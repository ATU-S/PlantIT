import '../../data/models/crop_model.dart';
import '../../data/models/space_analysis_model.dart';
import '../../data/local/kerala_crop_catalog.dart';

class RecommendationEngine {
  /// Evaluates crops based on the architecture formula:
  /// Compatibility Score = (Light × 0.4) + (Season × 0.3) + (Space × 0.2) + (Beginner × 0.1)
  static List<CropRecommendation> rankCrops({
    required double sunlightHours,
    required double areaSqMeters,
    required SpaceType spaceType,
    Season? overrideSeason,
    bool preferBeginnerFriendly = true,
  }) {
    final currentSeason = overrideSeason ?? detectKeralaSeason();
    final allCrops = KeralaCropCatalog.crops;
    final List<CropRecommendation> scoredList = [];

    for (final crop in allCrops) {
      // 1. Light Score (0 - 100)
      final double lightScore = _calculateLightScore(crop, sunlightHours);

      // 2. Season Score (0 - 100)
      final double seasonScore = _calculateSeasonScore(crop, currentSeason);

      // 3. Space Score (0 - 100)
      final double spaceScore = _calculateSpaceScore(crop, areaSqMeters, spaceType);

      // 4. Beginner Friendly Score (0 - 100)
      final double beginnerScore = _calculateDifficultyScore(crop, preferBeginnerFriendly);

      // Weighted Total Score (0 - 100)
      double totalScore = (lightScore * 0.40) +
          (seasonScore * 0.30) +
          (spaceScore * 0.20) +
          (beginnerScore * 0.10);

      // Small bonus if it produces quickly in small balcony spaces
      if (spaceType == SpaceType.balcony && crop.growthDurationDays <= 35) {
        totalScore = (totalScore + 4).clamp(0.0, 100.0);
      }

      final reason = _generateReason(
        crop: crop,
        lightScore: lightScore,
        seasonScore: seasonScore,
        spaceScore: spaceScore,
        sunlightHours: sunlightHours,
        season: currentSeason,
      );

      scoredList.add(CropRecommendation(
        crop: crop,
        score: double.parse(totalScore.toStringAsFixed(1)),
        lightScore: lightScore,
        seasonScore: seasonScore,
        spaceScore: spaceScore,
        beginnerScore: beginnerScore,
        recommendationReason: reason,
        matchingCompanionCropIds: crop.companionPlants,
      ));
    }

    // Sort descending by score
    scoredList.sort((a, b) => b.score.compareTo(a.score));
    return scoredList;
  }

  static double _calculateLightScore(Crop crop, double sunlightHours) {
    switch (crop.lightNeed) {
      case LightNeed.fullSun:
        if (sunlightHours >= 6.0) return 100.0;
        if (sunlightHours >= 5.0) return 85.0;
        if (sunlightHours >= 4.0) return 60.0;
        return 30.0;
      case LightNeed.partialSun:
        if (sunlightHours >= 3.0 && sunlightHours <= 6.0) return 100.0;
        if (sunlightHours > 6.0) return 80.0; // slightly too harsh for delicate greens
        return 50.0;
      case LightNeed.shadeBright:
        if (sunlightHours <= 4.0) return 100.0;
        if (sunlightHours <= 6.0) return 75.0;
        return 45.0;
    }
  }

  static double _calculateSeasonScore(Crop crop, Season season) {
    if (crop.idealSeasons.contains('Year-Round')) return 98.0;

    switch (season) {
      case Season.monsoon:
        if (crop.idealSeasons.contains('Monsoon')) return 100.0;
        if (crop.idealSeasons.contains('Summer')) return 40.0;
        return 65.0;
      case Season.postMonsoonWinter:
        if (crop.idealSeasons.contains('Winter') ||
            crop.idealSeasons.contains('Post-Monsoon')) {
          return 100.0;
        }
        return 70.0;
      case Season.summer:
        if (crop.idealSeasons.contains('Summer')) return 100.0;
        if (crop.idealSeasons.contains('Monsoon')) return 50.0;
        return 60.0;
      case Season.yearRound:
        return 95.0;
    }
  }

  static double _calculateSpaceScore(Crop crop, double areaSqMeters, SpaceType spaceType) {
    if (spaceType == SpaceType.windowsill) {
      // Windowsill requires compact shallow plants
      if (crop.minContainerDepthInches <= 8 && crop.spacingCm <= 20) {
        return 100.0;
      } else if (crop.minContainerDepthInches <= 10) {
        return 65.0;
      }
      return 25.0;
    }

    if (spaceType == SpaceType.balcony) {
      if (crop.minContainerDepthInches <= 12) return 95.0;
      return 75.0;
    }

    // Terrace & Backyard have ample space
    return 100.0;
  }

  static double _calculateDifficultyScore(Crop crop, bool preferBeginner) {
    if (!preferBeginner) return 90.0;
    switch (crop.difficulty) {
      case DifficultyLevel.beginner:
        return 100.0;
      case DifficultyLevel.intermediate:
        return 70.0;
      case DifficultyLevel.expert:
        return 45.0;
    }
  }

  static Season detectKeralaSeason() {
    final month = DateTime.now().month;
    if (month >= 6 && month <= 9) {
      return Season.monsoon; // Edavappathi & Thulam
    } else if (month >= 10 || month <= 1) {
      return Season.postMonsoonWinter; // Mild winter & harvest
    } else {
      return Season.summer; // Kumbham / Meenam heat
    }
  }

  static String _generateReason({
    required Crop crop,
    required double lightScore,
    required double seasonScore,
    required double spaceScore,
    required double sunlightHours,
    required Season season,
  }) {
    final reasons = <String>[];
    if (lightScore >= 90) {
      reasons.add('Thrives in your ${sunlightHours.toStringAsFixed(1)}h daily sunlight');
    }
    if (seasonScore >= 90) {
      reasons.add('Optimal for Kerala current season');
    }
    if (crop.difficulty == DifficultyLevel.beginner) {
      reasons.add('High success rate for urban growers');
    }
    if (reasons.isEmpty) {
      return 'Well balanced choice with proper container potting mix';
    }
    return reasons.join(' • ');
  }
}
