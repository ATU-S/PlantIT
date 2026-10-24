import 'crop_model.dart';

enum SpaceType {
  balcony,
  terrace,
  windowsill,
  backyard,
}

enum Season {
  monsoon, // June - Sept
  postMonsoonWinter, // Oct - Jan
  summer, // Feb - May
  yearRound,
}

/// The source used to derive observations from a photo of a growing space.
///
/// The app always keeps manual dimensions and sunlight as the source of truth:
/// a single image cannot reliably measure either value.
enum PhotoAnalysisSource {
  googleCloudVision,
  offlineFallback,
}

/// Descriptive observations from the growing-space photo.
///
/// These observations supplement the crop planner; they do not replace the
/// user's measurements or daily sunlight estimate.
class PhotoSpaceAnalysis {
  final PhotoAnalysisSource source;
  final List<String> detectedLabels;
  final List<String> detectedObjects;
  final double? brightnessPercent;
  final List<String> observations;
  final String statusMessage;

  const PhotoSpaceAnalysis({
    required this.source,
    this.detectedLabels = const [],
    this.detectedObjects = const [],
    this.brightnessPercent,
    this.observations = const [],
    required this.statusMessage,
  });

  bool get usedGoogleCloudVision =>
      source == PhotoAnalysisSource.googleCloudVision;
}

class CropRecommendation {
  final Crop crop;
  final double score; // 0.0 to 100.0
  final double lightScore;
  final double seasonScore;
  final double spaceScore;
  final double beginnerScore;
  final String recommendationReason;
  final List<String> matchingCompanionCropIds;

  CropRecommendation({
    required this.crop,
    required this.score,
    required this.lightScore,
    required this.seasonScore,
    required this.spaceScore,
    required this.beginnerScore,
    required this.recommendationReason,
    this.matchingCompanionCropIds = const [],
  });

  int get percentage => score.round().clamp(0, 100);
}

class LayoutGridCell {
  final int row;
  final int col;
  final Crop? crop;
  final bool hasCompanionSynergy;

  const LayoutGridCell({
    required this.row,
    required this.col,
    this.crop,
    this.hasCompanionSynergy = false,
  });
}

class ShoppingItem {
  final String name;
  final String category; // Seeds, Pots, Soil, Nutrients, Tools
  final String estimatedPriceKerala;
  final String nurseryTip;
  bool isChecked;

  ShoppingItem({
    required this.name,
    required this.category,
    required this.estimatedPriceKerala,
    required this.nurseryTip,
    this.isChecked = false,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'category': category,
        'estimatedPriceKerala': estimatedPriceKerala,
        'nurseryTip': nurseryTip,
        'isChecked': isChecked,
      };

  factory ShoppingItem.fromJson(Map<String, dynamic> json) => ShoppingItem(
        name: json['name'] as String,
        category: json['category'] as String,
        estimatedPriceKerala: json['estimatedPriceKerala'] as String,
        nurseryTip: json['nurseryTip'] as String,
        isChecked: json['isChecked'] as bool? ?? false,
      );
}

class SpaceAnalysisResult {
  final SpaceType spaceType;
  final double lengthMeters;
  final double widthMeters;
  final double sunlightHours;
  final Season detectedSeason;
  final List<CropRecommendation> recommendations;
  final List<List<LayoutGridCell>> gridLayout;
  final List<ShoppingItem> nurseryShoppingList;
  final String lightingInsight;
  final String keralaSeasonTip;
  final PhotoSpaceAnalysis? photoAnalysis;

  SpaceAnalysisResult({
    required this.spaceType,
    required this.lengthMeters,
    required this.widthMeters,
    required this.sunlightHours,
    required this.detectedSeason,
    required this.recommendations,
    required this.gridLayout,
    required this.nurseryShoppingList,
    required this.lightingInsight,
    required this.keralaSeasonTip,
    this.photoAnalysis,
  });
}
