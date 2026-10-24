import '../../data/models/crop_model.dart';
import '../../data/models/space_analysis_model.dart';

class LayoutPlanner {
  /// Generates a visual grid arrangement optimizing companion planting
  static List<List<LayoutGridCell>> generateCompanionGrid({
    required List<Crop> selectedCrops,
    int rows = 3,
    int cols = 3,
  }) {
    if (selectedCrops.isEmpty) {
      return List.generate(
        rows,
        (r) => List.generate(cols, (c) => LayoutGridCell(row: r, col: c)),
      );
    }

    final grid = List.generate(
      rows,
      (r) => List<LayoutGridCell?>.filled(cols, null),
    );

    int cropIndex = 0;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final currentCrop = selectedCrops[cropIndex % selectedCrops.length];
        cropIndex++;

        // Check if adjacent neighbors have companion synergy
        bool hasSynergy = false;
        if (r > 0 && grid[r - 1][c]?.crop != null) {
          final neighbor = grid[r - 1][c]!.crop!;
          if (currentCrop.companionPlants.contains(neighbor.id) ||
              neighbor.companionPlants.contains(currentCrop.id)) {
            hasSynergy = true;
          }
        }
        if (c > 0 && grid[r][c - 1]?.crop != null) {
          final neighbor = grid[r][c - 1]!.crop!;
          if (currentCrop.companionPlants.contains(neighbor.id) ||
              neighbor.companionPlants.contains(currentCrop.id)) {
            hasSynergy = true;
          }
        }

        grid[r][c] = LayoutGridCell(
          row: r,
          col: c,
          crop: currentCrop,
          hasCompanionSynergy: hasSynergy,
        );
      }
    }

    return List.generate(
      rows,
      (r) => List.generate(cols, (c) => grid[r][c]!),
    );
  }

  /// Generates custom nursery shopping checklist tailored to the user's crops and space
  static List<ShoppingItem> generateShoppingList({
    required List<Crop> crops,
    required double areaSqMeters,
    required SpaceType spaceType,
  }) {
    final list = <ShoppingItem>[];

    // Pots & Grow bags based on space
    final int estimatedGrowBags = (areaSqMeters * 3.5).ceil().clamp(3, 16);
    list.add(ShoppingItem(
      name: '$estimatedGrowBags x UV-Treated Green Grow Bags (12x12 & 15x15)',
      category: 'Containers',
      estimatedPriceKerala: '₹${estimatedGrowBags * 35}',
      nurseryTip: 'Choose 200+ GSM thick HDPE grow bags with drainage eyelets.',
    ));

    // Seeds / Seedlings
    for (final crop in crops) {
      list.add(ShoppingItem(
        name: '${crop.emoji} ${crop.name} seeds or nursery saplings',
        category: 'Seeds & Saplings',
        estimatedPriceKerala: '₹25 - ₹40',
        nurseryTip: 'Ask for certified ICAR or KAU disease-free seeds or healthy saplings.',
      ));
    }

    // Soil & Media
    final int compostBags = (estimatedGrowBags * 0.4).ceil().clamp(1, 4);
    list.add(ShoppingItem(
      name: '$compostBags x 5kg Vermicompost / Well-rotted Cow Dung',
      category: 'Growing Media',
      estimatedPriceKerala: '₹${compostBags * 100}',
      nurseryTip: 'Kerala pot mixes require 30% organic compost for sustained microbial life.',
    ));

    list.add(ShoppingItem(
      name: '1 x 5kg De-seeded Cocopeat Block',
      category: 'Growing Media',
      estimatedPriceKerala: '₹120',
      nurseryTip: 'Rinse cocopeat with water twice before expanding to wash away excess salt.',
    ));

    // Natural Kerala Organic Protection
    list.add(ShoppingItem(
      name: 'Cold-pressed Neem Oil (Vepennei) 100ml',
      category: 'Plant Health',
      estimatedPriceKerala: '₹85',
      nurseryTip: 'Mix 5ml in 1L water with a drop of liquid soap as proactive Kerala pest spray.',
    ));

    list.add(ShoppingItem(
      name: 'Bone Meal (Elumpu podi) 1kg',
      category: 'Nutrients',
      estimatedPriceKerala: '₹60',
      nurseryTip: 'Phosphorus boost for strong roots in tomatoes, chillies, and bhindi.',
    ));

    return list;
  }
}
