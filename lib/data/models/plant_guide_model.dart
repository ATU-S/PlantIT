class GrowthStep {
  final String stageTitle;
  final String durationRange; // e.g., "Days 1 - 5"
  final String description;
  final String actionableTip;
  final String iconEmoji;
  final List<String> checklist;

  const GrowthStep({
    required this.stageTitle,
    required this.durationRange,
    required this.description,
    required this.actionableTip,
    required this.iconEmoji,
    required this.checklist,
  });
}

class OrganicPestControlRecipe {
  final String name;
  final String targetPests;
  final List<String> ingredients;
  final String preparationSteps;
  final String applicationFrequency;

  const OrganicPestControlRecipe({
    required this.name,
    required this.targetPests,
    required this.ingredients,
    required this.preparationSteps,
    required this.applicationFrequency,
  });
}

class PlantGrowingGuide {
  final String cropId;
  final String cropName;
  final String malayalamName;
  final String summary;
  final String idealSoilMix;
  final List<GrowthStep> steps;
  final List<OrganicPestControlRecipe> organicRemedies;
  final List<String> commonPitfalls;
  final Map<String, String> aiFaqQuestions;

  const PlantGrowingGuide({
    required this.cropId,
    required this.cropName,
    required this.malayalamName,
    required this.summary,
    required this.idealSoilMix,
    required this.steps,
    required this.organicRemedies,
    required this.commonPitfalls,
    required this.aiFaqQuestions,
  });
}
