import 'dart:math';
import '../models/farm_model.dart';
import '../local/local_storage_service.dart';
import '../local/kerala_crop_catalog.dart';

class FarmRepository {
  final LocalStorageService _storage;
  List<Farm> _farms = [];
  String? _activeFarmId;

  FarmRepository(this._storage) {
    _loadFarms();
  }

  void _loadFarms() {
    _farms = _storage.getFarms();
    _activeFarmId = _storage.getActiveFarmId();

    // If no farms exist, initialize a rich sample Kerala Balcony Farm for immediate delight
    if (_farms.isEmpty) {
      final sampleFarm = Farm(
        id: 'farm_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Kochi Green Balcony 🌿',
        spaceType: 'Balcony',
        lengthMeters: 3.0,
        widthMeters: 1.5,
        sunlightHours: 5.5,
        createdAt: DateTime.now().subtract(const Duration(days: 14)),
        crops: [
          FarmCrop(
            id: 'crop_1',
            cropId: 'cheera_red',
            cropName: 'Red Amaranthus (Cheera)',
            emoji: '🥬',
            plantedDate: DateTime.now().subtract(const Duration(days: 14)),
            stage: GrowthStage.vegetative,
            healthScore: 98,
            lastWatered: DateTime.now().subtract(const Duration(hours: 18)),
            totalGrowthDays: 30,
            customNotes:
                'Planted in 12x12 UV grow bag. Lush red foliage emerging!',
          ),
          FarmCrop(
            id: 'crop_2',
            cropId: 'tomato_desi',
            cropName: 'Desi Bush Tomato',
            emoji: '🍅',
            plantedDate: DateTime.now().subtract(const Duration(days: 21)),
            stage: GrowthStage.flowering,
            healthScore: 92,
            lastWatered: DateTime.now().subtract(
              const Duration(hours: 26),
            ), // Needs water today
            totalGrowthDays: 75,
            customNotes: 'First cluster of yellow blossoms spotted!',
          ),
          FarmCrop(
            id: 'crop_3',
            cropId: 'chilli_kanthari',
            cropName: 'Kanthari White Bird Eye Chilli',
            emoji: '🌶️',
            plantedDate: DateTime.now().subtract(const Duration(days: 28)),
            stage: GrowthStage.fruiting,
            healthScore: 95,
            lastWatered: DateTime.now().subtract(const Duration(hours: 12)),
            totalGrowthDays: 90,
            customNotes: 'Pungent white chillies developing well.',
          ),
          FarmCrop(
            id: 'crop_4',
            cropId: 'tulsi_holy_basil',
            cropName: 'Krishna Tulsi',
            emoji: '🌿',
            plantedDate: DateTime.now().subtract(const Duration(days: 35)),
            stage: GrowthStage.readyToHarvest,
            healthScore: 99,
            lastWatered: DateTime.now().subtract(const Duration(hours: 8)),
            totalGrowthDays: 45,
            customNotes:
                'Companion planter next to tomato. Keeps whiteflies away.',
          ),
        ],
        activities: [
          CareActivity(
            id: 'act_1',
            farmCropId: 'crop_1',
            cropName: 'Red Amaranthus',
            type: ActivityType.planted,
            timestamp: DateTime.now().subtract(const Duration(days: 14)),
            pointsEarned: 10,
            notes: 'Sowed seeds in rich potting mix.',
          ),
          CareActivity(
            id: 'act_2',
            farmCropId: 'crop_2',
            cropName: 'Desi Tomato',
            type: ActivityType.water,
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
            pointsEarned: 2,
            notes: 'Morning watering with fermented kanji vellam.',
          ),
        ],
      );

      _farms = [sampleFarm];
      _activeFarmId = sampleFarm.id;
      _save();
    } else if (_activeFarmId == null ||
        !_farms.any((f) => f.id == _activeFarmId)) {
      _activeFarmId = _farms.first.id;
      _storage.setActiveFarmId(_activeFarmId!);
    }
  }

  List<Farm> getAllFarms() => List.unmodifiable(_farms);

  Farm? getActiveFarm() {
    if (_activeFarmId == null) return _farms.isNotEmpty ? _farms.first : null;
    try {
      return _farms.firstWhere((f) => f.id == _activeFarmId);
    } catch (_) {
      return _farms.isNotEmpty ? _farms.first : null;
    }
  }

  Future<void> setActiveFarm(String farmId) async {
    _activeFarmId = farmId;
    await _storage.setActiveFarmId(farmId);
  }

  Future<Farm> createFarm({
    required String name,
    required String spaceType,
    required double lengthMeters,
    required double widthMeters,
    required double sunlightHours,
    List<String> initialCropIds = const [],
  }) async {
    final farmId =
        'farm_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
    final List<FarmCrop> initialCrops = [];

    for (final cropId in initialCropIds) {
      final crop = KeralaCropCatalog.getById(cropId);
      if (crop != null) {
        initialCrops.add(
          FarmCrop(
            id: 'crop_${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(100)}',
            cropId: crop.id,
            cropName: crop.name,
            emoji: crop.emoji,
            plantedDate: DateTime.now(),
            stage: GrowthStage.seedling,
            totalGrowthDays: crop.growthDurationDays,
          ),
        );
      }
    }

    final newFarm = Farm(
      id: farmId,
      name: name,
      spaceType: spaceType,
      lengthMeters: lengthMeters,
      widthMeters: widthMeters,
      sunlightHours: sunlightHours,
      createdAt: DateTime.now(),
      crops: initialCrops,
    );

    _farms.add(newFarm);
    _activeFarmId = farmId;
    await _save();
    return newFarm;
  }

  Future<void> addCropToActiveFarm(String cropId) async {
    final farm = getActiveFarm();
    if (farm == null) return;

    final crop = KeralaCropCatalog.getById(cropId);
    if (crop == null) return;

    final newFarmCrop = FarmCrop(
      id: 'crop_${DateTime.now().microsecondsSinceEpoch}',
      cropId: crop.id,
      cropName: crop.name,
      emoji: crop.emoji,
      plantedDate: DateTime.now(),
      stage: GrowthStage.seedling,
      totalGrowthDays: crop.growthDurationDays,
    );

    farm.crops.add(newFarmCrop);
    farm.activities.insert(
      0,
      CareActivity(
        id: 'act_${DateTime.now().microsecondsSinceEpoch}',
        farmCropId: newFarmCrop.id,
        cropName: newFarmCrop.cropName,
        type: ActivityType.planted,
        timestamp: DateTime.now(),
        pointsEarned: 10,
        notes: 'Planted new ${crop.name} in garden.',
      ),
    );

    await _save();
  }

  Future<CareActivity> logCareActivity({
    required String farmCropId,
    required ActivityType type,
    String notes = '',
  }) async {
    final farm = getActiveFarm();
    if (farm == null) throw Exception('No active farm');

    final farmCrop = farm.crops.firstWhere((c) => c.id == farmCropId);

    int points = 2; // Default watering
    if (type == ActivityType.water) {
      points = 2;
      farmCrop.lastWatered = DateTime.now();
      farmCrop.healthScore = (farmCrop.healthScore + 2).clamp(0, 100);
    } else if (type == ActivityType.fertilize) {
      points = 5;
      farmCrop.healthScore = (farmCrop.healthScore + 5).clamp(0, 100);
    } else if (type == ActivityType.harvest) {
      points = 50;
      farmCrop.stage = GrowthStage.harvested;
    } else if (type == ActivityType.prune) {
      points = 4;
      farmCrop.healthScore = (farmCrop.healthScore + 2).clamp(0, 100);
    } else if (type == ActivityType.pestControl) {
      points = 6;
      farmCrop.healthScore = (farmCrop.healthScore + 4).clamp(0, 100);
    }

    final activity = CareActivity(
      id: 'act_${DateTime.now().microsecondsSinceEpoch}',
      farmCropId: farmCropId,
      cropName: farmCrop.cropName,
      type: type,
      timestamp: DateTime.now(),
      pointsEarned: points,
      notes: notes,
    );

    farm.activities.insert(0, activity);
    await _save();
    return activity;
  }

  Future<void> updateCropStage(String farmCropId, GrowthStage stage) async {
    final farm = getActiveFarm();
    if (farm == null) return;

    final farmCrop = farm.crops.firstWhere((c) => c.id == farmCropId);
    farmCrop.stage = stage;
    await _save();
  }

  Future<void> updateCropNotes(String farmCropId, String notes) async {
    final farm = getActiveFarm();
    if (farm == null) return;

    final farmCrop = farm.crops.firstWhere((c) => c.id == farmCropId);
    farmCrop.customNotes = notes.trim();
    await _save();
  }

  Future<void> _save() async {
    await _storage.saveFarms(_farms);
    if (_activeFarmId != null) {
      await _storage.setActiveFarmId(_activeFarmId!);
    }
  }
}
