class PlantBadge {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final int bonusPoints;
  final DateTime? unlockedAt;

  const PlantBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.bonusPoints,
    this.unlockedAt,
  });

  bool get isUnlocked => unlockedAt != null;

  PlantBadge copyWith({DateTime? unlockedAt}) {
    return PlantBadge(
      id: id,
      title: title,
      description: description,
      emoji: emoji,
      bonusPoints: bonusPoints,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'emoji': emoji,
        'bonusPoints': bonusPoints,
        'unlockedAt': unlockedAt?.toIso8601String(),
      };

  factory PlantBadge.fromJson(Map<String, dynamic> json) => PlantBadge(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        emoji: json['emoji'] as String,
        bonusPoints: json['bonusPoints'] as int,
        unlockedAt: json['unlockedAt'] != null
            ? DateTime.parse(json['unlockedAt'] as String)
            : null,
      );
}

class UserGamification {
  final String userId;
  String username;
  int totalPoints;
  int currentStreak;
  int bestStreak;
  DateTime? lastActiveDate;
  int totalWaterings;
  int totalPlantings;
  int totalHarvests;
  List<String> unlockedBadgeIds;

  UserGamification({
    required this.userId,
    required this.username,
    this.totalPoints = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.lastActiveDate,
    this.totalWaterings = 0,
    this.totalPlantings = 0,
    this.totalHarvests = 0,
    List<String>? unlockedBadgeIds,
  }) : unlockedBadgeIds = unlockedBadgeIds ?? [];

  String get gardenerLevel {
    if (totalPoints >= 1000) return 'Terrace Master Cultivator 🏆';
    if (totalPoints >= 500) return 'Green Thumb Veteran 🌿';
    if (totalPoints >= 250) return 'Urban Gardener 🌱';
    if (totalPoints >= 100) return 'Balcony Sprout 🪴';
    return 'Seedling Beginner 🌰';
  }

  int get nextLevelPoints {
    if (totalPoints >= 1000) return 2000;
    if (totalPoints >= 500) return 1000;
    if (totalPoints >= 250) return 500;
    if (totalPoints >= 100) return 250;
    return 100;
  }

  double get levelProgress {
    int prevThreshold = 0;
    int nextThreshold = 100;

    if (totalPoints >= 1000) {
      prevThreshold = 1000;
      nextThreshold = 2000;
    } else if (totalPoints >= 500) {
      prevThreshold = 500;
      nextThreshold = 1000;
    } else if (totalPoints >= 250) {
      prevThreshold = 250;
      nextThreshold = 500;
    } else if (totalPoints >= 100) {
      prevThreshold = 100;
      nextThreshold = 250;
    }

    final diff = nextThreshold - prevThreshold;
    if (diff <= 0) return 1.0;
    final progress = (totalPoints - prevThreshold) / diff;
    return progress.clamp(0.0, 1.0);
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'username': username,
        'totalPoints': totalPoints,
        'currentStreak': currentStreak,
        'bestStreak': bestStreak,
        'lastActiveDate': lastActiveDate?.toIso8601String(),
        'totalWaterings': totalWaterings,
        'totalPlantings': totalPlantings,
        'totalHarvests': totalHarvests,
        'unlockedBadgeIds': unlockedBadgeIds,
      };

  factory UserGamification.fromJson(Map<String, dynamic> json) =>
      UserGamification(
        userId: json['userId'] as String,
        username: json['username'] as String,
        totalPoints: json['totalPoints'] as int? ?? 0,
        currentStreak: json['currentStreak'] as int? ?? 0,
        bestStreak: json['bestStreak'] as int? ?? 0,
        lastActiveDate: json['lastActiveDate'] != null
            ? DateTime.parse(json['lastActiveDate'] as String)
            : null,
        totalWaterings: json['totalWaterings'] as int? ?? 0,
        totalPlantings: json['totalPlantings'] as int? ?? 0,
        totalHarvests: json['totalHarvests'] as int? ?? 0,
        unlockedBadgeIds:
            List<String>.from(json['unlockedBadgeIds'] as List? ?? []),
      );
}
