import 'package:flutter/material.dart';
import '../../data/models/farm_model.dart';
import '../../data/models/gamification_model.dart';
import '../../data/repositories/farm_repository.dart';
import 'gamification_view_model.dart';

class FarmViewModel extends ChangeNotifier {
  final FarmRepository _farmRepo;
  final GamificationViewModel _gamificationViewModel;

  bool _isLoading = false;
  String? _errorMessage;

  FarmViewModel({
    required FarmRepository farmRepository,
    required this._gamificationViewModel,
  }) : _farmRepo = farmRepository;

  Future<void> refresh() async {
    notifyListeners();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Farm> get farms => _farmRepo.getAllFarms();
  Farm? get activeFarm => _farmRepo.getActiveFarm();

  List<FarmCrop> get activeCrops => activeFarm?.crops ?? [];
  List<CareActivity> get recentActivities => activeFarm?.activities ?? [];

  List<FarmCrop> get cropsNeedingCare => activeCrops
      .where((c) => c.needsWaterToday && c.stage != GrowthStage.harvested)
      .toList();

  Future<void> switchFarm(String farmId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _farmRepo.setActiveFarm(farmId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Farm> createNewFarm({
    required String name,
    required String spaceType,
    required double lengthMeters,
    required double widthMeters,
    required double sunlightHours,
    List<String> initialCropIds = const [],
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final farm = await _farmRepo.createFarm(
        name: name,
        spaceType: spaceType,
        lengthMeters: lengthMeters,
        widthMeters: widthMeters,
        sunlightHours: sunlightHours,
        initialCropIds: initialCropIds,
      );

      // Award points for planting initial crops
      if (initialCropIds.isNotEmpty) {
        await _gamificationViewModel.awardPoints(
          points: initialCropIds.length * 10,
          isPlanting: true,
          uniqueCropsCount: activeCrops.map((c) => c.cropId).toSet().length,
        );
      }

      return farm;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<PlantBadge>> waterCrop(String farmCropId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final activity = await _farmRepo.logCareActivity(
        farmCropId: farmCropId,
        type: ActivityType.water,
        notes: 'Watered crop thoroughly',
      );

      final badges = await _gamificationViewModel.awardPoints(
        points: activity.pointsEarned,
        isWatering: true,
        uniqueCropsCount: activeCrops.map((c) => c.cropId).toSet().length,
      );
      return badges;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<PlantBadge>> waterAllPending() async {
    final pending = cropsNeedingCare;
    final List<PlantBadge> unlocked = [];
    for (final crop in pending) {
      final badges = await waterCrop(crop.id);
      unlocked.addAll(badges);
    }
    return unlocked;
  }

  Future<List<PlantBadge>> harvestCrop(String farmCropId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final activity = await _farmRepo.logCareActivity(
        farmCropId: farmCropId,
        type: ActivityType.harvest,
        notes: 'Harvested fresh produce',
      );

      final badges = await _gamificationViewModel.awardPoints(
        points: activity.pointsEarned,
        isHarvest: true,
        uniqueCropsCount: activeCrops.map((c) => c.cropId).toSet().length,
      );
      return badges;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<PlantBadge>> logCare(
    String farmCropId,
    ActivityType type, {
    String notes = '',
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final activity = await _farmRepo.logCareActivity(
        farmCropId: farmCropId,
        type: type,
        notes: notes,
      );
      return _gamificationViewModel.awardPoints(
        points: activity.pointsEarned,
        uniqueCropsCount: activeCrops.map((c) => c.cropId).toSet().length,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<PlantBadge>> plantCrop(String cropId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _farmRepo.addCropToActiveFarm(cropId);
      final badges = await _gamificationViewModel.awardPoints(
        points: 10,
        isPlanting: true,
        uniqueCropsCount: activeCrops.map((c) => c.cropId).toSet().length,
      );
      return badges;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStage(String farmCropId, GrowthStage stage) async {
    await _farmRepo.updateCropStage(farmCropId, stage);
    notifyListeners();
  }

  Future<void> updateNotes(String farmCropId, String notes) async {
    await _farmRepo.updateCropNotes(farmCropId, notes);
    notifyListeners();
  }
}
