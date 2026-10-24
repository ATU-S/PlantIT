import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../../data/models/space_analysis_model.dart';
import 'recommendation_engine.dart';
import 'layout_planner.dart';

class SpaceVisionService {
  final String? geminiApiKey;

  SpaceVisionService({this.geminiApiKey});

  /// Analyzes growing space from user parameters and optional image
  Future<SpaceAnalysisResult> analyzeSpace({
    required SpaceType spaceType,
    required double lengthMeters,
    required double widthMeters,
    required double sunlightHours,
    Uint8List? imageBytes,
    String? mimeType,
  }) async {
    // If user provided a Gemini API Key and an image, we can query Gemini multimodal
    if (geminiApiKey != null && geminiApiKey!.trim().isNotEmpty && imageBytes != null) {
      try {
        final geminiResult = await _queryGeminiVision(
          imageBytes: imageBytes,
          mimeType: mimeType ?? 'image/jpeg',
          spaceType: spaceType,
        );
        if (geminiResult != null) {
          return geminiResult;
        }
      } catch (_) {
        // Fallback to local intelligent analysis
      }
    }

    // Default intelligent rule-based engine
    return _synthesizeAnalysis(
      spaceType: spaceType,
      lengthMeters: lengthMeters,
      widthMeters: widthMeters,
      sunlightHours: sunlightHours,
    );
  }

  SpaceAnalysisResult _synthesizeAnalysis({
    required SpaceType spaceType,
    required double lengthMeters,
    required double widthMeters,
    required double sunlightHours,
  }) {
    final areaSqMeters = lengthMeters * widthMeters;
    final season = RecommendationEngine.detectKeralaSeason();

    // Top crop recommendations
    final recommendations = RecommendationEngine.rankCrops(
      sunlightHours: sunlightHours,
      areaSqMeters: areaSqMeters,
      spaceType: spaceType,
      overrideSeason: season,
    );

    final top5 = recommendations.take(5).toList();
    final topCrops = top5.map((r) => r.crop).toList();

    // Generate grid layout (e.g. 3x3 for balcony/terrace)
    final grid = LayoutPlanner.generateCompanionGrid(
      selectedCrops: topCrops,
      rows: 3,
      cols: 3,
    );

    // Generate nursery shopping list
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
        keralaSeasonTip = 'Year-round tropical climate supports continuous leafy vegetable rotation.';
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
    );
  }

  Future<SpaceAnalysisResult?> _queryGeminiVision({
    required Uint8List imageBytes,
    required String mimeType,
    required SpaceType spaceType,
  }) async {
    final base64Image = base64Encode(imageBytes);
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$geminiApiKey');

    final prompt = '''
You are an expert Kerala urban agronomist analyzing a photo of a ${spaceType.name}.
Analyze the lighting, sun direction, shadows, and approximate dimensions in meters.
Return ONLY a valid JSON object matching this structure:
{
  "estimatedSunHours": 5.5,
  "lengthMeters": 2.5,
  "widthMeters": 1.5,
  "lightingObservation": "Bright southern exposure with afternoon partial shade."
}
''';

    final body = {
      "contents": [
        {
          "parts": [
            {"text": prompt},
            {
              "inline_data": {
                "mime_type": mimeType,
                "data": base64Image,
              }
            }
          ]
        }
      ]
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final text = jsonResponse['candidates'][0]['content']['parts'][0]['text'] as String;
      // Clean JSON formatting markdown
      final cleanText = text.replaceAll('```json', '').replaceAll('```', '').trim();
      final parsed = jsonDecode(cleanText);

      final sun = (parsed['estimatedSunHours'] as num).toDouble();
      final length = (parsed['lengthMeters'] as num).toDouble();
      final width = (parsed['widthMeters'] as num).toDouble();

      return _synthesizeAnalysis(
        spaceType: spaceType,
        lengthMeters: length,
        widthMeters: width,
        sunlightHours: sun,
      );
    }
    return null;
  }
}
