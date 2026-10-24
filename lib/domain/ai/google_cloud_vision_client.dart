import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../data/models/space_analysis_model.dart';

/// Minimal REST client for Google Cloud Vision's `images:annotate` endpoint.
///
/// This is intentionally used only for local development builds at present.
/// The app receives the API key through a Dart define and must move this call
/// behind an authenticated backend before a public release.
class GoogleCloudVisionClient {
  static const _endpoint = 'https://vision.googleapis.com/v1/images:annotate';

  final String apiKey;
  final http.Client _httpClient;

  GoogleCloudVisionClient({
    required this.apiKey,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  Future<PhotoSpaceAnalysis> analyzeGrowingSpace(Uint8List imageBytes) async {
    if (apiKey.trim().isEmpty) {
      throw const GoogleCloudVisionException('No Google Cloud Vision API key is configured.');
    }

    final endpoint = Uri.parse(_endpoint).replace(
      queryParameters: {'key': apiKey},
    );
    final response = await _httpClient
        .post(
          endpoint,
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({
            'requests': [
              {
                'image': {'content': base64Encode(imageBytes)},
                'features': const [
                  {'type': 'LABEL_DETECTION', 'maxResults': 8},
                  {'type': 'OBJECT_LOCALIZATION', 'maxResults': 8},
                  {'type': 'IMAGE_PROPERTIES'},
                ],
              },
            ],
          }),
        )
        .timeout(const Duration(seconds: 15));

    final Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } on FormatException {
      throw const GoogleCloudVisionException(
        'Google Cloud Vision returned an unreadable response.',
      );
    }

    if (response.statusCode != 200) {
      throw GoogleCloudVisionException(_errorMessage(body, response.statusCode));
    }

    final responses = body['responses'];
    if (responses is! List || responses.isEmpty || responses.first is! Map) {
      throw const GoogleCloudVisionException(
        'Google Cloud Vision returned no image analysis.',
      );
    }

    final result = Map<String, dynamic>.from(responses.first as Map);
    final embeddedError = result['error'];
    if (embeddedError is Map) {
      throw GoogleCloudVisionException(_errorMessage(
        {'error': embeddedError},
        response.statusCode,
      ));
    }

    final labels = _readNamedAnnotations(result['labelAnnotations']);
    final objects = _readNamedAnnotations(result['localizedObjectAnnotations']);
    final brightness = _readBrightness(result['imagePropertiesAnnotation']);
    final observations = _buildObservations(
      labels: labels,
      objects: objects,
      brightnessPercent: brightness,
    );

    return PhotoSpaceAnalysis(
      source: PhotoAnalysisSource.googleCloudVision,
      detectedLabels: labels,
      detectedObjects: objects,
      brightnessPercent: brightness,
      observations: observations,
      statusMessage: 'Photo observations provided by Google Cloud Vision.',
    );
  }

  List<String> _readNamedAnnotations(dynamic annotations) {
    if (annotations is! List) return const [];

    final seen = <String>{};
    final names = <String>[];
    for (final annotation in annotations) {
      if (annotation is! Map) continue;
      final rawName = annotation['description'] ?? annotation['name'];
      final rawScore = annotation['score'];
      final score = rawScore is num ? rawScore.toDouble() : 1.0;
      if (rawName is! String || rawName.trim().isEmpty || score < 0.45) {
        continue;
      }
      final name = rawName.trim();
      if (seen.add(name.toLowerCase())) names.add(name);
    }
    return names;
  }

  double? _readBrightness(dynamic imageProperties) {
    if (imageProperties is! Map) return null;
    final dominantColors = imageProperties['dominantColors'];
    if (dominantColors is! Map) return null;
    final colors = dominantColors['colors'];
    if (colors is! List || colors.isEmpty) return null;

    var totalWeight = 0.0;
    var totalLuminance = 0.0;
    for (final entry in colors) {
      if (entry is! Map) continue;
      final color = entry['color'];
      if (color is! Map) continue;
      final red = (color['red'] as num?)?.toDouble() ?? 0.0;
      final green = (color['green'] as num?)?.toDouble() ?? 0.0;
      final blue = (color['blue'] as num?)?.toDouble() ?? 0.0;
      final weight = (entry['pixelFraction'] as num?)?.toDouble() ??
          (entry['score'] as num?)?.toDouble() ??
          1.0;
      totalLuminance += (0.2126 * red + 0.7152 * green + 0.0722 * blue) * weight;
      totalWeight += weight;
    }

    if (totalWeight == 0) return null;
    return ((totalLuminance / totalWeight) / 255 * 100).clamp(0.0, 100.0);
  }

  List<String> _buildObservations({
    required List<String> labels,
    required List<String> objects,
    required double? brightnessPercent,
  }) {
    final detectedTerms = {...labels, ...objects}
        .map((item) => item.toLowerCase())
        .join(' ');
    final observations = <String>[];

    if (detectedTerms.contains('plant') ||
        detectedTerms.contains('flowerpot') ||
        detectedTerms.contains('potted')) {
      observations.add(
        'Existing plants or containers appear in the photo. Leave airflow between grow bags, especially during monsoon months.',
      );
    }
    if (detectedTerms.contains('sky') ||
        detectedTerms.contains('balcony') ||
        detectedTerms.contains('roof') ||
        detectedTerms.contains('terrace')) {
      observations.add(
        'The photo appears to show an outdoor growing area. Confirm the daily direct-sunlight hours before planting fruiting crops.',
      );
    }
    if (brightnessPercent != null) {
      if (brightnessPercent >= 65) {
        observations.add(
          'The image appears bright. Brightness from one photo is not a substitute for tracking direct sunlight across the day.',
        );
      } else if (brightnessPercent <= 35) {
        observations.add(
          'The image appears relatively shaded. Recheck the manual sunlight setting before choosing full-sun crops.',
        );
      }
    }
    if (observations.isEmpty) {
      observations.add(
        'Photo observations are descriptive. Use the manual dimensions and sunlight controls below for the planting plan.',
      );
    }
    return observations;
  }

  String _errorMessage(Map<String, dynamic> body, int statusCode) {
    final error = body['error'];
    if (error is Map && error['message'] is String) {
      return 'Google Cloud Vision could not analyze this photo: ${error['message']}';
    }
    return 'Google Cloud Vision could not analyze this photo (HTTP $statusCode).';
  }
}

class GoogleCloudVisionException implements Exception {
  final String message;

  const GoogleCloudVisionException(this.message);

  @override
  String toString() => message;
}
