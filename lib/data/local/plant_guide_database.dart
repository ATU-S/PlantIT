import '../models/plant_guide_model.dart';

class PlantGuideDatabase {
  static final Map<String, PlantGrowingGuide> _guides = {
    'cheera_red': const PlantGrowingGuide(
      cropId: 'cheera_red',
      cropName: 'Red Amaranthus (Cheera)',
      malayalamName: 'ചുവപ്പ് ചീര',
      summary: 'Fastest growing tropical leafy green in Kerala. Highly nutritious and ideal for grow bags, terrace, and balcony boxes.',
      idealSoilMix: '1:1:1 ratio of Red Soil, Well-composted Cow Dung (dry) or Vermicompost, and Coir Pith. Add 50g Bone Meal + 10g Neem Cake per bag.',
      steps: [
        GrowthStep(
          stageTitle: '1. Seed Prep & Sowing',
          durationRange: 'Day 1 - 4',
          description: 'Mix tiny seeds with dry river sand (1:5 ratio) for even broadcasting. Sow on top of loose moist soil and cover with a thin sprinkle of fine soil.',
          actionableTip: 'Cover the pot with newspaper or banana leaf for 48 hours to retain moisture until germination sprouts appear.',
          iconEmoji: '🌱',
          checklist: [
            'Mix seeds with dry sand or wood ash',
            'Sow 0.5 cm deep max',
            'Mist with water gently (do not flood)',
            'Keep in partial morning sun',
          ],
        ),
        GrowthStep(
          stageTitle: '2. Seedling Thinning',
          durationRange: 'Day 8 - 12',
          description: 'Dense seedlings will compete for nutrition and get thin stems. Thin out weak seedlings, leaving 10-15 cm gap between strong plants.',
          actionableTip: 'The thinned-out baby greens are delicious microgreens you can add directly to salads!',
          iconEmoji: '🌿',
          checklist: [
            'Maintain 12-15 cm spacing',
            'Water in early morning before 8:30 AM',
            'Apply diluted rice water (kanji vellam) diluted 1:3 with water',
          ],
        ),
        GrowthStep(
          stageTitle: '3. Rapid Growth & Nutrition',
          durationRange: 'Day 15 - 25',
          description: 'Cheera enters fast foliage production. Needs steady nitrogen and moisture to prevent premature flowering.',
          actionableTip: 'Spray Panchagavya (3% dilution) or Cow Dung slurry once a week for lush ruby-red leaf color.',
          iconEmoji: '🪴',
          checklist: [
            'Add 1 fistful vermicompost per plant on Day 15',
            'Check underside of leaves for leaf-webber caterpillars',
            'Avoid watering leaves late in the evening to stop fungus',
          ],
        ),
        GrowthStep(
          stageTitle: '4. First Harvest & Regrowth',
          durationRange: 'Day 28 - 45',
          description: 'Harvest by clipping top stems 5 cm above base instead of uprooting. This triggers 2-3 extra rounds of fresh side shoots.',
          actionableTip: 'Harvest early morning when leaves are crisp and full of turgor pressure.',
          iconEmoji: '🧺',
          checklist: [
            'Cut with clean shears above the lowest nodes',
            'Apply diluted liquid manure right after cutting to boost regrowth',
            'Harvest every 7-10 days thereafter',
          ],
        ),
      ],
      organicRemedies: [
        OrganicPestControlRecipe(
          name: 'Neem-Soap Spray for Leaf Webber & Aphids',
          targetPests: 'Leaf webber caterpillar, leaf spot, aphids',
          ingredients: [
            'Neem Oil: 5 ml (1 tsp)',
            'Khadi/Bar soap solution or mild detergent: 2 ml (emulsifier)',
            'Clean water: 1 Litre',
          ],
          preparationSteps: 'Vigorously mix soap in warm water first until dissolved, then blend neem oil until a creamy white emulsion forms. Pour into spray bottle.',
          applicationFrequency: 'Spray top and bottom of leaves every 7-10 days in the late afternoon (after 4:30 PM).',
        ),
        OrganicPestControlRecipe(
          name: 'Fermented Kanji Vellam & Buttermilk Tonic',
          targetPests: 'Fungal leaf blight, pale yellowing, viral mosaic',
          ingredients: [
            'Fermented rice gruel water (2 days old): 500 ml',
            'Sour buttermilk (pulippaaya moru): 250 ml',
            'Fresh water: 2 Litres',
          ],
          preparationSteps: 'Mix both liquids with water. Stir well and let rest for 30 minutes before spraying.',
          applicationFrequency: 'Spray once every 14 days. Acts as an organic antifungal and foliar nutrition booster.',
        ),
      ],
      commonPitfalls: [
        'Premature flowering (Bolting): Caused by water stress or excessive afternoon heat. Keep soil evenly moist.',
        'Stem Rot during heavy monsoon: Ensure grow bags have drainage holes cleared of mud and kept off bare concrete.',
      ],
      aiFaqQuestions: {
        'Why are my Cheera leaves developing white webbing?': 'This is the Cheera leaf-webber (Spoladea recurvalis). Hand-pick folded leaves immediately and spray the Neem-Soap emulsion late evening.',
        'Can I grow Cheera in 100% shade?': 'No, Cheera requires at least 4 hours of direct sun to develop vibrant anthocyanin pigments and thick, crisp stems.',
        'How often should I water in Kerala summer?': 'Twice daily: gently at 7:00 AM and again at 5:00 PM if the topsoil feels dry.',
      },
    ),
    'kanthari_mulaku': const PlantGrowingGuide(
      cropId: 'kanthari_mulaku',
      cropName: 'Bird\'s Eye Chilli (Kanthari)',
      malayalamName: 'കാന്താരി മുളക്',
      summary: 'Perennial powerhouse of Kerala homesteads. Extremely high capsaicin, thrives in semi-shade and yields spicy chillies for 3-5 years.',
      idealSoilMix: 'Equal parts Garden Soil, Well-rotted Cow Manure, Coir pith + 1 cup Wood Ash (Potash for abundant flowering).',
      steps: [
        GrowthStep(
          stageTitle: '1. Seed Germination',
          durationRange: 'Day 1 - 14',
          description: 'Kanthari seeds take 7-14 days to germinate. Soak mature ripe white/green pods seeds in buttermilk for 3 hours prior to sowing.',
          actionableTip: 'Soaking in sour buttermilk breaks seed dormancy and protects from seed-borne viral infections.',
          iconEmoji: '🌱',
          checklist: [
            'Sow in seed nursery tray or small cups',
            'Keep in warm humid shade',
            'Maintain gentle moisture',
          ],
        ),
        GrowthStep(
          stageTitle: '2. Transplanting to Grow Bag',
          durationRange: 'Day 30 - 35',
          description: 'When seedling has 4-5 true leaves and is 10 cm tall, transplant gently into a 30x30x30 cm sturdy grow bag.',
          actionableTip: 'Transplant in the late afternoon to prevent transplant shock.',
          iconEmoji: '🪴',
          checklist: [
            'Plant at same depth as nursery container',
            'Water immediately with diluted cow dung slurry',
            'Shade for 2 days before placing in bright spot',
          ],
        ),
        GrowthStep(
          stageTitle: '3. Pinching & Bushy Growth',
          durationRange: 'Day 45 - 60',
          description: 'Pinch the apical terminal tip when plant reaches 25 cm height. This forces multiple side branches resulting in 3x higher yields.',
          actionableTip: 'Add 1 tablespoon crushed eggshells or lime (chunnambu) to prevent calcium deficiency blossom end rot.',
          iconEmoji: '✂️',
          checklist: [
            'Pinch top growing tip',
            'Apply wood ash around the root drip-line',
            'Mulch base with dry leaves to retain moisture',
          ],
        ),
        GrowthStep(
          stageTitle: '4. Continuous Fruiting & Harvesting',
          durationRange: 'Day 75 - 1000+',
          description: 'Kanthari starts flowering profusely. Pick chillies when they turn ivory white or pale green. Plants produce continuously for multiple years.',
          actionableTip: 'Prune dead twigs after monsoon to stimulate fresh bearing wood.',
          iconEmoji: '🌶️',
          checklist: [
            'Harvest every 3-4 days',
            'Re-fertilize with vermicompost monthly',
            'Apply Fish Amino Acid foliar spray for flower retention',
          ],
        ),
      ],
      organicRemedies: [
        OrganicPestControlRecipe(
          name: 'Garlic-Chilli-Asafoetida (Kaayam) Spray',
          targetPests: 'Leaf curl virus, thrips, mites, whiteflies',
          ingredients: [
            'Crushed Garlic: 50 grams',
            'Green Chillies: 25 grams',
            'Hing / Asafoetida (Kaayam): 10 grams',
            'Water: 1 Litre',
          ],
          preparationSteps: 'Grind garlic and chillies, dissolve asafoetida in warm water. Strain through muslin cloth and dilute 1:5 with water before spraying.',
          applicationFrequency: 'Spray weekly on leaf undersides to prevent leaf curling and drive away sap-sucking pests.',
        ),
        OrganicPestControlRecipe(
          name: 'Fish Amino Acid (Meen Amilam)',
          targetPests: 'Flower drop booster and organic foliar nutrient',
          ingredients: [
            'Sardine / small sea fish (chopped): 500g',
            'Organic Jaggery (Sharkkara): 500g',
          ],
          preparationSteps: 'Layer equal parts fish and jaggery in an airtight container for 25 days in shade. Filter the honey-like liquid.',
          applicationFrequency: 'Dilute 2 ml per 1 Litre of water and spray on flowers every 15 days.',
        ),
      ],
      commonPitfalls: [
        'Leaf Curling: Caused by mites or thrips. Never overwater and apply the garlic-chilli spray immediately.',
        'Flower Dropping: Occurs in excessive midday heat. Shift grow bag to a spot with filtered sunlight under netting or coconut tree shade.',
      ],
      aiFaqQuestions: {
        'Why are my Kanthari leaves curling upwards?': 'Upward leaf curling is typically caused by tiny mites or thrips sucking sap. Spray the Garlic-Kaayam emulsion once every 5 days.',
        'Does Kanthari need full blistering sun?': 'No! Kanthari produces best in dappled light / partial sunlight (3-5 hours sun), making it ideal for shaded balconies and coconut groves.',
      },
    ),
    'thakkali': const PlantGrowingGuide(
      cropId: 'thakkali',
      cropName: 'Tomato (Thakkali)',
      malayalamName: 'തക്കാളി',
      summary: 'High yielding variety for container farming. Thrives in Kerala post-monsoon and winter months with proper staking and calcium.',
      idealSoilMix: '1 part Garden Soil, 1 part Vermicompost, 1 part Coir Pith + 1 tbsp Lime/Chunnambu (prevents fruit rot) + 10g Trichoderma.',
      steps: [
        GrowthStep(
          stageTitle: '1. Seed Raising',
          durationRange: 'Day 1 - 20',
          description: 'Sow in seedling trays. Provide bright morning light once sprouted.',
          actionableTip: 'Treat seeds with Trichoderma bio-fungicide to prevent damping-off disease.',
          iconEmoji: '🌱',
          checklist: ['Sow 0.5 cm deep', 'Keep moist not waterlogged', 'Keep in sunny window'],
        ),
        GrowthStep(
          stageTitle: '2. Transplanting & Staking',
          durationRange: 'Day 25 - 35',
          description: 'Transplant when 15 cm tall. Plant deeply up to the first leaves for extra root development. Insert a 1.5m bamboo stake immediately.',
          actionableTip: 'Staking early avoids disturbing roots later.',
          iconEmoji: '🪴',
          checklist: ['Deep planting', 'Tie loosely to bamboo stake', 'Mulch bag top with dried leaves'],
        ),
        GrowthStep(
          stageTitle: '3. Sucker Pruning & Flowering',
          durationRange: 'Day 40 - 55',
          description: 'Pinch off "suckers" (side shoots growing in the armpits between main stem and branches) to channel energy into plump tomatoes.',
          actionableTip: 'Gently tap or shake the flower clusters at midday to help self-pollination.',
          iconEmoji: '🍅',
          checklist: ['Prune lowest leaves touching soil', 'Spray egg-amino or seaweed extract', 'Maintain steady watering'],
        ),
        GrowthStep(
          stageTitle: '4. Ripening & Harvesting',
          durationRange: 'Day 65 - 85',
          description: 'Pick fruits when they turn pinkish-red (vine-ripened gives the sweetest Kerala country tomato flavor).',
          actionableTip: 'Reduce watering slightly when fruits start turning red to prevent skin cracking.',
          iconEmoji: '🧺',
          checklist: ['Pick with shears', 'Harvest continuously every 3 days', 'Feed liquid compost weekly'],
        ),
      ],
      organicRemedies: [
        OrganicPestControlRecipe(
          name: 'Pseudomonas fluorescens Bio-Shield',
          targetPests: 'Bacterial wilt, early blight, root rot',
          ingredients: ['Pseudomonas bio-powder: 20 grams', 'Water: 1 Litre'],
          preparationSteps: 'Mix thoroughly and let stand for 15 minutes.',
          applicationFrequency: 'Drench root zone every 14 days and spray leaves during humid weather.',
        ),
      ],
      commonPitfalls: [
        'Black bottom on tomatoes (Blossom End Rot): Calcium deficiency caused by irregular watering. Keep moisture steady and add agricultural lime.',
      ],
      aiFaqQuestions: {
        'Why are my tomato flowers falling without forming fruit?': 'High temperature or lack of wind for self-pollination. Gently shake flower stalks at noon and spray Fish Amino acid.',
      },
    ),
  };

  /// Returns custom guide if present, or dynamically synthesizes an expert guide for any catalog crop
  static PlantGrowingGuide getGuideForCrop(String cropId, String cropName, String malayalamName) {
    if (_guides.containsKey(cropId)) {
      return _guides[cropId]!;
    }

    // Dynamic synthesis for any other Kerala crop (Bhindi, Brinjal, Beans, Mint, Curry Leaf, etc.)
    return PlantGrowingGuide(
      cropId: cropId,
      cropName: cropName,
      malayalamName: malayalamName,
      summary: 'Comprehensive Kerala agro-climatic cultivation plan tailored for $cropName ($malayalamName) in urban containers and rooftop setups.',
      idealSoilMix: '1:1:1 blend of Red Soil, Vermicompost / Well-cured Farmyard Manure, and Coir Pith with 50g Neem cake per container.',
      steps: [
        GrowthStep(
          stageTitle: '1. Seed/Sapling Establishment',
          durationRange: 'Days 1 - 10',
          description: 'Prepare clean potting mix with proper drainage. Sow seeds at twice their thickness depth or plant healthy root-ball seedling.',
          actionableTip: 'Keep top 2 cm soil moist with a fine water mist spray. Avoid direct midday sun for the first 3 days.',
          iconEmoji: '🌱',
          checklist: ['Inspect container drainage holes', 'Mix organic base soil', 'Moisten medium before planting'],
        ),
        GrowthStep(
          stageTitle: '2. Vegetative Canopy Development',
          durationRange: 'Days 15 - 35',
          description: 'Plant develops strong root anchorage and leaf crown. Needs steady sunlight and balanced organic nitrogen.',
          actionableTip: 'Feed with fermented rice water (Kanji vellam) diluted with 3 parts fresh water every 10 days.',
          iconEmoji: '🌿',
          checklist: ['Maintain 4-6 hours direct sun', 'Weed container surface gently', 'Mulch with dried grass or leaves'],
        ),
        GrowthStep(
          stageTitle: '3. Flowering & Pest Prevention',
          durationRange: 'Days 40 - 60',
          description: 'Buds and flowers emerge. Watch out for seasonal sap-sucking insects and leaf folders.',
          actionableTip: 'Spray 5ml/L neem oil emulsion in late afternoon to maintain healthy blooms without harming honeybees.',
          iconEmoji: '🌸',
          checklist: ['Apply fistful of vermicompost + bone meal', 'Check underside of leaves', 'Support with wooden stake if tall'],
        ),
        GrowthStep(
          stageTitle: '4. Peak Harvest & Sustenance',
          durationRange: 'Harvest Stage',
          description: 'Harvest fresh produce at optimal tenderness for maximum kitchen flavor and nutrition.',
          actionableTip: 'Always harvest early morning when crispness and cellular moisture are at peak.',
          iconEmoji: '🧺',
          checklist: ['Cut with clean sharp scissors', 'Never yank stems harshly', 'Replenish organic manure after major harvest'],
        ),
      ],
      organicRemedies: [
        OrganicPestControlRecipe(
          name: 'Universal Kerala Organic Neem Shield',
          targetPests: 'Caterpillars, aphids, mealybugs, leaf miners',
          ingredients: [
            'Pure Neem Oil: 5 ml',
            'Organic liquid soap / Bar soap shavings: 2 ml',
            'Water: 1 Litre',
          ],
          preparationSteps: 'Emulsify soap in lukewarm water, then whisk in neem oil until milky. Spray immediately.',
          applicationFrequency: 'Apply every 10 days after 4:30 PM.',
        ),
      ],
      commonPitfalls: [
        'Overwatering in monsoon: Soggy roots starve of oxygen. Lift grow bags off flat flooring on bricks.',
      ],
      aiFaqQuestions: {
        'How much sun does this plant need?': 'Most Kerala vegetable varieties require at least 4-6 hours of unfiltered sun for optimum harvest.',
        'What should I do if leaves turn pale green?': 'Usually a sign of nitrogen wash-out from heavy rains. Feed with cow dung slurry or organic vermicompost.',
      },
    );
  }
}
