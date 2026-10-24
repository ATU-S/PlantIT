import 'dart:typed_data';

import '../../data/models/space_analysis_model.dart';
import 'google_cloud_vision_client.dart';
import 'layout_planner.dart';
import 'recommendation_engine.dart';

/// Combines optional photo observations with PlantIT's local crop-planning
/// rules. A photo is never used to overwrite the user's dimensions or daily
/// direct-sunlight estimate because Google Cloud Vision cannot determine those
/// reliably from one image.
class SpaceVisionService {
  static const _compiledVisionApiKey = String.fromEnvironment(
    'GOOGLE_CLOUD_VISION_API_KEY',
  );

  final GoogleCloudVisionClient? _googleCloudVisionClient;

  Uint8List? _lastAnalyzedImage;
  PhotoSpaceAnalysis? _lastPhotoAnalysis;

  SpaceVisionService({
    String? googleCloudVisionApiKey,
    GoogleCloudVisionClient? googleCloudVisionClient,
  }) : _googleCloudVisionClient =
           googleCloudVisionClient ??
           _clientForKey(googleCloudVisionApiKey ?? _compiledVisionApiKey);

  bool get isGoogleCloudVisionConfigured => _googleCloudVisionClient != null;

  /// Analyzes a growing space using user-entered measurements and, when a
  /// local development API key is provided, photo observations from Vision.
  Future<SpaceAnalysisResult> analyzeSpace({
    required SpaceType spaceType,
    required double lengthMeters,
    required double widthMeters,
    required double sunlightHours,
    Uint8List? imageBytes,
  }) async {
    final photoAnalysis = await _analyzePhotoIfNeeded(imageBytes);

    return _synthesizeAnalysis(
      spaceType: spaceType,
      lengthMeters: lengthMeters,
      widthMeters: widthMeters,
      sunlightHours: sunlightHours,
      photoAnalysis: photoAnalysis,
    );
  }

  static GoogleCloudVisionClient? _clientForKey(String apiKey) {
    if (apiKey.trim().isEmpty) return null;
    return GoogleCloudVisionClient(apiKey: apiKey.trim());
  }

  Future<PhotoSpaceAnalysis?> _analyzePhotoIfNeeded(
    Uint8List? imageBytes,
  ) async {
    if (imageBytes == null) return null;

    // Slider changes and space-type changes reuse the selected bytes. Cache
    // the remote response so the same image is not uploaded repeatedly.
    if (identical(imageBytes, _lastAnalyzedImage) &&
        _lastPhotoAnalysis != null) {
      return _lastPhotoAnalysis;
    }

    PhotoSpaceAnalysis photoAnalysis;
    if (_googleCloudVisionClient == null) {
      photoAnalysis = const PhotoSpaceAnalysis(
        source: PhotoAnalysisSource.offlineFallback,
        statusMessage:
            'Photo saved locally. Add a Google Cloud Vision key to this local build to enable photo observations.',
      );
    } else {
      try {
        photoAnalysis = await _googleCloudVisionClient.analyzeGrowingSpace(
          imageBytes,
        );
      } catch (_) {
        photoAnalysis = const PhotoSpaceAnalysis(
          source: PhotoAnalysisSource.offlineFallback,
          statusMessage:
              'Google Cloud Vision was unavailable. This plan uses your manual measurements and local crop data.',
        );
      }
    }

    _lastAnalyzedImage = imageBytes;
    _lastPhotoAnalysis = photoAnalysis;
    return photoAnalysis;
  }

  SpaceAnalysisResult _synthesizeAnalysis({
    required SpaceType spaceType,
    required double lengthMeters,
    required double widthMeters,
    required double sunlightHours,
    PhotoSpaceAnalysis? photoAnalysis,
  }) {
    final areaSqMeters = lengthMeters * widthMeters;
    final season = RecommendationEngine.detectKeralaSeason();

    final recommendations = RecommendationEngine.rankCrops(
      sunlightHours: sunlightHours,
      areaSqMeters: areaSqMeters,
      spaceType: spaceType,
      overrideSeason: season,
    );

    final top5 = recommendations.take(5).toList();
    final topCrops = top5.map((recommendation) => recommendation.crop).toList();

    final grid = LayoutPlanner.generateCompanionGrid(
      selectedCrops: topCrops,
      rows: 3,
      cols: 3,
    );

    final shoppingList = LayoutPlanner.generateShoppingList(
      crops: topCrops,
      areaSqMeters: areaSqMeters,
      spaceType: spaceType,
    );

    String lightingInsight;
    if (sunlightHours >= 6) {
      lightingInsight =
          'Direct Sunlight (>6 hrs/day): Perfect for fruiting crops like Tomatoes, Kanthari Chillies, and Okra.';
    } else if (sunlightHours >= 4) {
      lightingInsight =
          'Partial Sun (4-6 hrs/day): Ideal for Kerala Red Amaranthus (Cheera), Mint, Coriander, and Bush Pepper.';
    } else {
      lightingInsight =
          'Shaded / Filtered Light (<4 hrs/day): Best suited for fast-growing Microgreens, Palak, Aloe Vera, and Ginger.';
    }

    String keralaSeasonTip;
    switch (season) {
      case Season.monsoon:
        keralaSeasonTip =
            'Monsoon Active: Ensure grow bag drain holes are unclogged. Keep seedlings covered during heavy downpours.';
      case Season.postMonsoonWinter:
        keralaSeasonTip =
            'Post-Monsoon Peak: Best planting window in Kerala! Mild temperatures accelerate flowering and fruit set.';
      case Season.summer:
        keralaSeasonTip =
            'Summer Season: Provide morning watering and thin 50% green agro-shade netting to protect tender foliage.';
      case Season.yearRound:
        keralaSeasonTip =
            'Year-round tropical climate supports continuous leafy vegetable rotation.';
    }

    return SpaceAnalysisResult(
      spaceType: spaceType,
      lengthMeters: lengthMeters,
      widthMeters: widthMeters,
      sunlightHours: sunlightHours,
      detectedSeason: season,
      recommendations: top5,
      gridLayout: grid,
      nurseryShoppingList: shoppingList,
      lightingInsight: lightingInsight,
      keralaSeasonTip: keralaSeasonTip,
      photoAnalysis: photoAnalysis,
    );
  }
}
