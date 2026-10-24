import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plantit/data/models/space_analysis_model.dart';
import 'package:plantit/domain/ai/recommendation_engine.dart';
import 'package:plantit/domain/ai/layout_planner.dart';
import 'package:plantit/data/local/kerala_crop_catalog.dart';
import 'package:plantit/data/local/local_storage_service.dart';
import 'package:plantit/data/repositories/gamification_repository.dart';
import 'package:plantit/data/repositories/farm_repository.dart';
import 'package:plantit/data/models/farm_model.dart';

void main() {
  group('AI Recommendation Engine & Agronomy Logic', () {
    test('Calculates crop ranking with formula', () {
      final recs = RecommendationEngine.rankCrops(
        sunlightHours: 6.0,
        areaSqMeters: 4.5,
        spaceType: SpaceType.balcony,
        overrideSeason: Season.postMonsoonWinter,
      );

      expect(recs.isNotEmpty, isTrue);
      expect(recs.first.score, greaterThanOrEqualTo(recs.last.score));
      expect(recs.first.score, inInclusiveRange(0.0, 100.0));
      expect(recs.first.recommendationReason, isNotEmpty);
    });

    test('Generates companion planting grid with synergy detection', () {
      final tomato = KeralaCropCatalog.getById('tomato_desi')!;
      final tulsi = KeralaCropCatalog.getById('tulsi_holy_basil')!;

      final grid = LayoutPlanner.generateCompanionGrid(
        selectedCrops: [tomato, tulsi],
        rows: 2,
        cols: 2,
      );

      expect(grid.length, 2);
      expect(grid[0].length, 2);
      // Verify symbiotic pairing detected
      final hasSynergy = grid.any(
        (row) => row.any((cell) => cell.hasCompanionSynergy),
      );
      expect(hasSynergy, isTrue);
    });

    test('Generates tailored Kerala nursery shopping list', () {
      final crops = KeralaCropCatalog.crops.take(3).toList();
      final list = LayoutPlanner.generateShoppingList(
        crops: crops,
        areaSqMeters: 3.0,
        spaceType: SpaceType.balcony,
      );

      expect(list.isNotEmpty, isTrue);
      expect(list.any((item) => item.category == 'Containers'), isTrue);
      expect(list.any((item) => item.category == 'Plant Health'), isTrue);
    });
  });

  group('Gamification System & Streaks', () {
    test('Awards points and unlocks badges', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await LocalStorageService.init();
      final repo = GamificationRepository(storage);

      expect(repo.getGamification().totalPoints, 20); // Initial bonus

      final badges = await repo.awardPoints(
        points: 10,
        isPlanting: true,
        uniqueCropsCount: 1,
      );

      expect(repo.getGamification().totalPoints, greaterThan(20));
      expect(repo.getGamification().currentStreak, 1);
      expect(badges.any((b) => b.id == 'sprout_starter'), isTrue);
    });
  });

  group('Garden care journal', () {
    test('persists care actions and crop notes', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await LocalStorageService.init();
      final repository = FarmRepository(storage);
      final crop = repository.getActiveFarm()!.crops.first;
      final startingHealth = crop.healthScore;

      final activity = await repository.logCareActivity(
        farmCropId: crop.id,
        type: ActivityType.fertilize,
        notes: 'Added vermicompost.',
      );
      await repository.updateCropNotes(crop.id, 'Moved closer to morning sun.');

      expect(activity.pointsEarned, 5);
      expect(crop.healthScore, greaterThan(startingHealth));
      expect(crop.customNotes, 'Moved closer to morning sun.');
      expect(
        repository.getActiveFarm()!.activities.first.type,
        ActivityType.fertilize,
      );
    });
  });
}
