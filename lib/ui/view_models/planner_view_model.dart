import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/space_analysis_model.dart';
import '../../domain/ai/space_vision_service.dart';
import 'farm_view_model.dart';

class PlannerViewModel extends ChangeNotifier {
  final SpaceVisionService _visionService;
  final FarmViewModel _farmViewModel;

  SpaceType _selectedSpaceType = SpaceType.balcony;
  double _lengthMeters = 3.0;
  double _widthMeters = 1.5;
  double _sunlightHours = 5.0;
  XFile? _selectedImage;
  Uint8List? _imageBytes;

  bool _isAnalyzing = false;
  SpaceAnalysisResult? _analysisResult;
  final Set<String> _selectedCropIdsForFarm = {};

  PlannerViewModel({
    required this._visionService,
    required this._farmViewModel,
  }) {
    // Run an initial quick analysis so the user immediately sees recommendations
    analyzeCurrentSpace();
  }

  SpaceType get selectedSpaceType => _selectedSpaceType;
  double get lengthMeters => _lengthMeters;
  double get widthMeters => _widthMeters;
  double get sunlightHours => _sunlightHours;
  XFile? get selectedImage => _selectedImage;
  Uint8List? get imageBytes => _imageBytes;
  bool get isAnalyzing => _isAnalyzing;
  bool get isVisionConfigured => _visionService.isGoogleCloudVisionConfigured;
  SpaceAnalysisResult? get analysisResult => _analysisResult;
  Set<String> get selectedCropIdsForFarm => _selectedCropIdsForFarm;

  void setSpaceType(SpaceType type) {
    _selectedSpaceType = type;
    // Set smart sensible defaults based on space type
    switch (type) {
      case SpaceType.balcony:
        _lengthMeters = 3.0;
        _widthMeters = 1.5;
        _sunlightHours = 5.0;
        break;
      case SpaceType.terrace:
        _lengthMeters = 6.0;
        _widthMeters = 4.0;
        _sunlightHours = 7.5;
        break;
      case SpaceType.windowsill:
        _lengthMeters = 1.2;
        _widthMeters = 0.4;
        _sunlightHours = 3.5;
        break;
      case SpaceType.backyard:
        _lengthMeters = 8.0;
        _widthMeters = 5.0;
        _sunlightHours = 6.5;
        break;
    }
    notifyListeners();
    analyzeCurrentSpace();
  }

  void updateDimensions({double? length, double? width, double? sunlight}) {
    if (length != null) _lengthMeters = length;
    if (width != null) _widthMeters = width;
    if (sunlight != null) _sunlightHours = sunlight;
    notifyListeners();
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final file = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (file != null) {
        _selectedImage = file;
        _imageBytes = await file.readAsBytes();
        notifyListeners();
        await analyzeCurrentSpace();
      }
    } catch (_) {
      // User cancelled or platform picker issue
    }
  }

  void toggleCropSelection(String cropId) {
    if (_selectedCropIdsForFarm.contains(cropId)) {
      _selectedCropIdsForFarm.remove(cropId);
    } else {
      _selectedCropIdsForFarm.add(cropId);
    }
    notifyListeners();
  }

  Future<void> analyzeCurrentSpace() async {
    _isAnalyzing = true;
    notifyListeners();

    try {
      _analysisResult = await _visionService.analyzeSpace(
        spaceType: _selectedSpaceType,
        lengthMeters: _lengthMeters,
        widthMeters: _widthMeters,
        sunlightHours: _sunlightHours,
        imageBytes: _imageBytes,
      );

      // Pre-select top 3 crops for convenience
      _selectedCropIdsForFarm.clear();
      if (_analysisResult != null) {
        for (final rec in _analysisResult!.recommendations.take(3)) {
          _selectedCropIdsForFarm.add(rec.crop.id);
        }
      }
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  Future<void> createFarmFromPlan(String farmName) async {
    final cropsToPlant = _selectedCropIdsForFarm.isNotEmpty
        ? _selectedCropIdsForFarm.toList()
        : (_analysisResult?.recommendations.take(3).map((r) => r.crop.id).toList() ?? []);

    await _farmViewModel.createNewFarm(
      name: farmName.trim().isNotEmpty
          ? farmName.trim()
          : '${_selectedSpaceType.name.toUpperCase()} Garden 🌱',
      spaceType: _selectedSpaceType.name,
      lengthMeters: _lengthMeters,
      widthMeters: _widthMeters,
      sunlightHours: _sunlightHours,
      initialCropIds: cropsToPlant,
    );
  }
}
