import '../models/gamification_model.dart';
import '../local/local_storage_service.dart';

class GamificationRepository {
  final LocalStorageService _storage;
  late UserGamification _gamification;

  final List<PlantBadge> _allBadges = [
    const PlantBadge(
      id: 'sprout_starter',
      title: 'Green Sprout',
      description: 'Planted your first crop in PlantIT',
      emoji: '🌱',
      bonusPoints: 10,
    ),
    const PlantBadge(
      id: 'hydrator_pro',
      title: 'Monsoon Hydrator',
      description: 'Watered plants 5 times consistently',
      emoji: '💧',
      bonusPoints: 15,
    ),
    const PlantBadge(
      id: 'streak_7',
      title: '7-Day Green Streak',
      description: 'Cared for your garden 7 days in a row',
      emoji: '🔥',
      bonusPoints: 25,
    ),
    const PlantBadge(
      id: 'harvest_master',
      title: 'Bountiful Harvester',
      description: 'Harvested your first fresh homegrown produce',
      emoji: '🧺',
      bonusPoints: 100,
    ),
    const PlantBadge(
      id: 'kerala_botanist',
      title: 'Kerala Agro Champion',
      description: 'Growing 3+ indigenous Kerala varieties',
      emoji: '🌴',
      bonusPoints: 50,
    ),
    const PlantBadge(
      id: 'companion_planter',
      title: 'Permaculture Master',
      description: 'Paired natural companion plants to repel pests',
      emoji: '🐝',
      bonusPoints: 30,
    ),
  ];

  GamificationRepository(this._storage) {
    _gamification = _storage.getGamification();
    _checkDailyStreak();
  }

  UserGamification getGamification() => _gamification;

  List<PlantBadge> getBadges() {
    return _allBadges.map((b) {
      final isUnlocked = _gamification.unlockedBadgeIds.contains(b.id);
      return b.copyWith(
        unlockedAt: isUnlocked ? (_gamification.lastActiveDate ?? DateTime.now()) : null,
      );
    }).toList();
  }

  /// Adds points and verifies badge unlocks. Returns any newly unlocked badges!
  Future<List<PlantBadge>> awardPoints({
    required int points,
    bool isWatering = false,
    bool isPlanting = false,
    bool isHarvest = false,
    int uniqueCropsCount = 0,
  }) async {
    _gamification.totalPoints += points;
    if (isWatering) _gamification.totalWaterings++;
    if (isPlanting) _gamification.totalPlantings++;
    if (isHarvest) _gamification.totalHarvests++;

    _updateStreakActivity();

    final List<PlantBadge> newlyUnlocked = [];

    // Check Badge Criteria
    void tryUnlock(String badgeId) {
      if (!_gamification.unlockedBadgeIds.contains(badgeId)) {
        _gamification.unlockedBadgeIds.add(badgeId);
        final badge = _allBadges.firstWhere((b) => b.id == badgeId);
        _gamification.totalPoints += badge.bonusPoints;
        newlyUnlocked.add(badge.copyWith(unlockedAt: DateTime.now()));
      }
    }

    if (_gamification.totalPlantings >= 1) {
      tryUnlock('sprout_starter');
    }
    if (_gamification.totalWaterings >= 5) {
      tryUnlock('hydrator_pro');
    }
    if (_gamification.currentStreak >= 7) {
      tryUnlock('streak_7');
    }
    if (_gamification.totalHarvests >= 1) {
      tryUnlock('harvest_master');
    }
    if (uniqueCropsCount >= 3) {
      tryUnlock('kerala_botanist');
    }

    await _storage.saveGamification(_gamification);
    return newlyUnlocked;
  }

  void _checkDailyStreak() {
    final now = DateTime.now();
    final lastActive = _gamification.lastActiveDate;
    if (lastActive == null) return;

    final difference = DateTime(now.year, now.month, now.day)
        .difference(DateTime(lastActive.year, lastActive.month, lastActive.day))
        .inDays;

    if (difference > 1) {
      // Streak broken
      _gamification.currentStreak = 0;
      _storage.saveGamification(_gamification);
    }
  }

  void _updateStreakActivity() {
    final now = DateTime.now();
    final lastActive = _gamification.lastActiveDate;

    if (lastActive == null) {
      _gamification.currentStreak = 1;
      _gamification.bestStreak = 1;
    } else {
      final diffDays = DateTime(now.year, now.month, now.day)
          .difference(DateTime(lastActive.year, lastActive.month, lastActive.day))
          .inDays;

      if (diffDays == 1) {
        // Next consecutive day!
        _gamification.currentStreak += 1;
        if (_gamification.currentStreak > _gamification.bestStreak) {
          _gamification.bestStreak = _gamification.currentStreak;
        }
      } else if (diffDays == 0) {
        // Same day activity, maintain streak
        if (_gamification.currentStreak == 0) _gamification.currentStreak = 1;
      } else {
        // Broken streak, restart at 1
        _gamification.currentStreak = 1;
      }
    }

    _gamification.lastActiveDate = now;
  }
}
