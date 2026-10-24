enum GrowthStage {
  germination,
  seedling,
  vegetative,
  flowering,
  fruiting,
  readyToHarvest,
  harvested,
}

enum ActivityType {
  water,
  fertilize,
  pestControl,
  prune,
  harvest,
  planted,
}

class CareActivity {
  final String id;
  final String farmCropId;
  final String cropName;
  final ActivityType type;
  final DateTime timestamp;
  final int pointsEarned;
  final String notes;

  CareActivity({
    required this.id,
    required this.farmCropId,
    required this.cropName,
    required this.type,
    required this.timestamp,
    required this.pointsEarned,
    this.notes = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'farmCropId': farmCropId,
        'cropName': cropName,
        'type': type.name,
        'timestamp': timestamp.toIso8601String(),
        'pointsEarned': pointsEarned,
        'notes': notes,
      };

  factory CareActivity.fromJson(Map<String, dynamic> json) => CareActivity(
        id: json['id'] as String,
        farmCropId: json['farmCropId'] as String,
        cropName: json['cropName'] as String,
        type: ActivityType.values.byName(json['type'] as String),
        timestamp: DateTime.parse(json['timestamp'] as String),
        pointsEarned: json['pointsEarned'] as int,
        notes: json['notes'] as String? ?? '',
      );
}

class FarmCrop {
  final String id;
  final String cropId;
  final String cropName;
  final String emoji;
  final DateTime plantedDate;
  GrowthStage stage;
  int healthScore; // 0 to 100
  DateTime lastWatered;
  final int totalGrowthDays;
  String customNotes;

  FarmCrop({
    required this.id,
    required this.cropId,
    required this.cropName,
    required this.emoji,
    required this.plantedDate,
    this.stage = GrowthStage.seedling,
    this.healthScore = 95,
    DateTime? lastWatered,
    required this.totalGrowthDays,
    this.customNotes = '',
  }) : lastWatered = lastWatered ?? plantedDate;

  int get daysSincePlanted => DateTime.now().difference(plantedDate).inDays;

  double get progressRatio {
    if (totalGrowthDays <= 0) return 0.0;
    final ratio = daysSincePlanted / totalGrowthDays;
    return ratio.clamp(0.0, 1.0);
  }

  bool get needsWaterToday {
    final difference = DateTime.now().difference(lastWatered);
    return difference.inHours >= 20; // Needs watering roughly daily or next morning
  }

  String get stageTitle {
    switch (stage) {
      case GrowthStage.germination:
        return 'Sprouting 🌱';
      case GrowthStage.seedling:
        return 'Seedling 🌿';
      case GrowthStage.vegetative:
        return 'Vegetative 🪴';
      case GrowthStage.flowering:
        return 'Flowering 🌸';
      case GrowthStage.fruiting:
        return 'Fruiting 🍅';
      case GrowthStage.readyToHarvest:
        return 'Ready to Harvest! 🧺';
      case GrowthStage.harvested:
        return 'Harvested 🎉';
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'cropId': cropId,
        'cropName': cropName,
        'emoji': emoji,
        'plantedDate': plantedDate.toIso8601String(),
        'stage': stage.name,
        'healthScore': healthScore,
        'lastWatered': lastWatered.toIso8601String(),
        'totalGrowthDays': totalGrowthDays,
        'customNotes': customNotes,
      };

  factory FarmCrop.fromJson(Map<String, dynamic> json) => FarmCrop(
        id: json['id'] as String,
        cropId: json['cropId'] as String,
        cropName: json['cropName'] as String,
        emoji: json['emoji'] as String? ?? '🌱',
        plantedDate: DateTime.parse(json['plantedDate'] as String),
        stage: GrowthStage.values.byName(json['stage'] as String),
        healthScore: json['healthScore'] as int? ?? 90,
        lastWatered: DateTime.parse(json['lastWatered'] as String),
        totalGrowthDays: json['totalGrowthDays'] as int,
        customNotes: json['customNotes'] as String? ?? '',
      );
}

class Farm {
  final String id;
  String name;
  String spaceType; // Balcony, Terrace, Windowsill, Backyard
  double lengthMeters;
  double widthMeters;
  double sunlightHours;
  final DateTime createdAt;
  List<FarmCrop> crops;
  List<CareActivity> activities;

  Farm({
    required this.id,
    required this.name,
    required this.spaceType,
    required this.lengthMeters,
    required this.widthMeters,
    required this.sunlightHours,
    required this.createdAt,
    List<FarmCrop>? crops,
    List<CareActivity>? activities,
  })  : crops = crops ?? [],
        activities = activities ?? [];

  double get areaSqMeters => lengthMeters * widthMeters;
  double get areaSqFt => areaSqMeters * 10.7639;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'spaceType': spaceType,
        'lengthMeters': lengthMeters,
        'widthMeters': widthMeters,
        'sunlightHours': sunlightHours,
        'createdAt': createdAt.toIso8601String(),
        'crops': crops.map((c) => c.toJson()).toList(),
        'activities': activities.map((a) => a.toJson()).toList(),
      };

  factory Farm.fromJson(Map<String, dynamic> json) => Farm(
        id: json['id'] as String,
        name: json['name'] as String,
        spaceType: json['spaceType'] as String,
        lengthMeters: (json['lengthMeters'] as num).toDouble(),
        widthMeters: (json['widthMeters'] as num).toDouble(),
        sunlightHours: (json['sunlightHours'] as num).toDouble(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        crops: (json['crops'] as List?)
                ?.map((c) => FarmCrop.fromJson(c as Map<String, dynamic>))
                .toList() ??
            [],
        activities: (json['activities'] as List?)
                ?.map((a) => CareActivity.fromJson(a as Map<String, dynamic>))
                .toList() ??
            [],
      );
}
