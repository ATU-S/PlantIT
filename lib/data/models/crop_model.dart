enum CropCategory {
  vegetable,
  herb,
  leafyGreen,
  spice,
  medicinal,
  fruit,
}

enum WaterNeed {
  low,
  moderate,
  high,
}

enum LightNeed {
  fullSun, // 6+ hours
  partialSun, // 3-6 hours
  shadeBright, // 2-3 hours indirect
}

enum DifficultyLevel {
  beginner,
  intermediate,
  expert,
}

class Crop {
  final String id;
  final String name;
  final String malayalamName;
  final String scientificName;
  final CropCategory category;
  final WaterNeed waterNeed;
  final LightNeed lightNeed;
  final int minSunHours;
  final List<String> idealSeasons;
  final int growthDurationDays;
  final DifficultyLevel difficulty;
  final int spacingCm;
  final int minContainerDepthInches;
  final List<String> companionPlants;
  final List<String> antagonisticPlants;
  final String soilRequirements;
  final String careTips;
  final String harvestGuide;
  final String emoji;

  const Crop({
    required this.id,
    required this.name,
    required this.malayalamName,
    required this.scientificName,
    required this.category,
    required this.waterNeed,
    required this.lightNeed,
    required this.minSunHours,
    required this.idealSeasons,
    required this.growthDurationDays,
    required this.difficulty,
    required this.spacingCm,
    required this.minContainerDepthInches,
    required this.companionPlants,
    required this.antagonisticPlants,
    required this.soilRequirements,
    required this.careTips,
    required this.harvestGuide,
    required this.emoji,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'malayalamName': malayalamName,
        'scientificName': scientificName,
        'category': category.name,
        'waterNeed': waterNeed.name,
        'lightNeed': lightNeed.name,
        'minSunHours': minSunHours,
        'idealSeasons': idealSeasons,
        'growthDurationDays': growthDurationDays,
        'difficulty': difficulty.name,
        'spacingCm': spacingCm,
        'minContainerDepthInches': minContainerDepthInches,
        'companionPlants': companionPlants,
        'antagonisticPlants': antagonisticPlants,
        'soilRequirements': soilRequirements,
        'careTips': careTips,
        'harvestGuide': harvestGuide,
        'emoji': emoji,
      };

  factory Crop.fromJson(Map<String, dynamic> json) => Crop(
        id: json['id'] as String,
        name: json['name'] as String,
        malayalamName: json['malayalamName'] as String,
        scientificName: json['scientificName'] as String,
        category: CropCategory.values.byName(json['category'] as String),
        waterNeed: WaterNeed.values.byName(json['waterNeed'] as String),
        lightNeed: LightNeed.values.byName(json['lightNeed'] as String),
        minSunHours: json['minSunHours'] as int,
        idealSeasons: List<String>.from(json['idealSeasons'] as List),
        growthDurationDays: json['growthDurationDays'] as int,
        difficulty: DifficultyLevel.values.byName(json['difficulty'] as String),
        spacingCm: json['spacingCm'] as int,
        minContainerDepthInches: json['minContainerDepthInches'] as int,
        companionPlants: List<String>.from(json['companionPlants'] as List),
        antagonisticPlants: List<String>.from(json['antagonisticPlants'] as List),
        soilRequirements: json['soilRequirements'] as String,
        careTips: json['careTips'] as String,
        harvestGuide: json['harvestGuide'] as String,
        emoji: json['emoji'] as String,
      );

  String get difficultyLabel {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return 'Beginner Friendly';
      case DifficultyLevel.intermediate:
        return 'Moderate';
      case DifficultyLevel.expert:
        return 'Advanced';
    }
  }

  String get lightLabel {
    switch (lightNeed) {
      case LightNeed.fullSun:
        return 'Full Sun (6+ hrs)';
      case LightNeed.partialSun:
        return 'Partial Sun (4-6 hrs)';
      case LightNeed.shadeBright:
        return 'Bright Indirect (2-4 hrs)';
    }
  }

  String get waterLabel {
    switch (waterNeed) {
      case WaterNeed.low:
        return 'Low (Every 2-3 days)';
      case WaterNeed.moderate:
        return 'Moderate (Daily/Alternate)';
      case WaterNeed.high:
        return 'High (Daily)';
    }
  }
}
