import 'package:flutter/material.dart';
import '../../data/models/gamification_model.dart';
import '../../data/repositories/gamification_repository.dart';

class GamificationViewModel extends ChangeNotifier {
  final GamificationRepository _repo;

  GamificationViewModel({required GamificationRepository repository})
      : _repo = repository;

  UserGamification get gamification => _repo.getGamification();
  int get totalPoints => gamification.totalPoints;
  int get currentStreak => gamification.currentStreak;
  int get bestStreak => gamification.bestStreak;
  String get gardenerLevel => gamification.gardenerLevel;
  double get levelProgress => gamification.levelProgress;
  int get nextLevelPoints => gamification.nextLevelPoints;

  List<PlantBadge> get allBadges => _repo.getBadges();
  List<PlantBadge> get unlockedBadges => allBadges.where((b) => b.isUnlocked).toList();
  List<PlantBadge> get lockedBadges => allBadges.where((b) => !b.isUnlocked).toList();

  Future<List<PlantBadge>> awardPoints({
    required int points,
    bool isWatering = false,
    bool isPlanting = false,
    bool isHarvest = false,
    int uniqueCropsCount = 0,
  }) async {
    final newlyUnlocked = await _repo.awardPoints(
      points: points,
      isWatering: isWatering,
      isPlanting: isPlanting,
      isHarvest: isHarvest,
      uniqueCropsCount: uniqueCropsCount,
    );
    notifyListeners();
    return newlyUnlocked;
  }
}
