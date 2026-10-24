import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:plantit/core/theme/app_colors.dart';
import 'package:plantit/data/models/space_analysis_model.dart';
import 'package:plantit/ui/view_models/planner_view_model.dart';

class AiPlannerScreen extends StatefulWidget {
  final VoidCallback? onFarmCreated;

  const AiPlannerScreen({super.key, this.onFarmCreated});

  @override
  State<AiPlannerScreen> createState() => _AiPlannerScreenState();
}

class _AiPlannerScreenState extends State<AiPlannerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plannerVM = context.watch<PlannerViewModel>();
    final result = plannerVM.analysisResult;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Farm Planner 🤖🌱'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.wb_sunny_outlined, size: 20), text: 'AI Analysis'),
            Tab(icon: Icon(Icons.grid_view_rounded, size: 20), text: 'Layout Grid'),
            Tab(icon: Icon(Icons.shopping_bag_outlined, size: 20), text: 'Nursery List'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: AI Input & Crop Recommendations
          _buildAnalysisTab(context, plannerVM, result),

          // Tab 2: Companion Planting Layout Grid
          _buildLayoutGridTab(context, plannerVM, result),

          // Tab 3: Nursery Shopping Checklist
          _buildShoppingTab(context, plannerVM, result),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton.icon(
            onPressed: plannerVM.isAnalyzing
                ? null
                : () => _showStartFarmDialog(context, plannerVM),
            icon: const Icon(Icons.rocket_launch, size: 18),
            label: Text(
              'Plant This Farm (${plannerVM.selectedCropIdsForFarm.length} Crops Selected)',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisTab(
    BuildContext context,
    PlannerViewModel vm,
    SpaceAnalysisResult? result,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Space Type Selector Chips
          const Text(
            '1. Select Your Growing Space',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: SpaceType.values.map((type) {
                final isSelected = vm.selectedSpaceType == type;
                String emoji = '🏢';
                if (type == SpaceType.balcony) emoji = '🪴 Balcony';
                if (type == SpaceType.terrace) emoji = '☀️ Terrace / Rooftop';
                if (type == SpaceType.windowsill) emoji = '🪟 Windowsill';
                if (type == SpaceType.backyard) emoji = '🏡 Backyard';

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(emoji),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (_) => vm.setSpaceType(type),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 18),

          // 2. Photo Upload or Camera Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: vm.isVisionConfigured
                        ? AppColors.primary.withAlpha(15)
                        : AppColors.warning.withAlpha(18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: vm.isVisionConfigured
                          ? AppColors.primary.withAlpha(80)
                          : AppColors.warning.withAlpha(110),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        vm.isVisionConfigured ? Icons.check_circle : Icons.info_outline,
                        color: vm.isVisionConfigured ? AppColors.primary : AppColors.warning,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          vm.isVisionConfigured
                              ? 'Google Cloud Vision is active for photo analysis.'
                              : 'Photo analysis is offline only. Add GOOGLE_CLOUD_VISION_API_KEY to enable AI image detection.',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: vm.isVisionConfigured ? AppColors.primary : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (vm.imageBytes != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      vm.imageBytes!,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    height: 110,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withAlpha(40)),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined, size: 36, color: AppColors.primary),
                        SizedBox(height: 6),
                        Text(
                          'Upload photo of balcony or rooftop',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                        Text(
                          'AI detects light angle & space boundaries',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => vm.pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt, size: 16),
                      label: const Text('Take Photo'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () => vm.pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library, size: 16),
                      label: const Text('Choose File'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 3. Space & Sunlight Sliders
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Direct Sunlight Exposure', style: TextStyle(fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.sunYellow.withAlpha(30),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${vm.sunlightHours.toStringAsFixed(1)} hrs/day',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: vm.sunlightHours,
                  min: 1.0,
                  max: 10.0,
                  divisions: 18,
                  activeColor: AppColors.sunYellow,
                  onChanged: (val) {
                    vm.updateDimensions(sunlight: val);
                  },
                  onChangeEnd: (_) => vm.analyzeCurrentSpace(),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Dimensions: ${vm.lengthMeters.toStringAsFixed(1)}m × ${vm.widthMeters.toStringAsFixed(1)}m (${(vm.lengthMeters * vm.widthMeters * 10.76).toStringAsFixed(0)} sq ft)'),
                  ],
                ),
                Slider(
                  value: vm.lengthMeters,
                  min: 1.0,
                  max: 12.0,
                  divisions: 22,
                  activeColor: AppColors.primary,
                  onChanged: (val) => vm.updateDimensions(length: val),
                  onChangeEnd: (_) => vm.analyzeCurrentSpace(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 4. AI Recommendations Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Top Recommended Crops (Kerala)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              if (result != null)
                Text(
                  '${result.recommendations.length} Matches',
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
            ],
          ),
          const SizedBox(height: 4),
          if (result != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                '${result.lightingInsight}\n${result.keralaSeasonTip}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),

          if (vm.isAnalyzing)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 8),
                    Text('AI analyzing sunlight, season, & Kerala agronomy...'),
                  ],
                ),
              ),
            )
          else if (result != null)
            ...result.recommendations.map((rec) {
              final isSelected = vm.selectedCropIdsForFarm.contains(rec.crop.id);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : Colors.grey.shade200,
                    width: isSelected ? 2.0 : 1.0,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceMuted,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(rec.crop.emoji, style: const TextStyle(fontSize: 26)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        rec.crop.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: rec.percentage >= 85
                                            ? AppColors.primary.withAlpha(20)
                                            : Colors.amber.withAlpha(30),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${rec.percentage}% Match',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: rec.percentage >= 85
                                              ? AppColors.primary
                                              : Colors.orange.shade800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${rec.crop.malayalamName} • Harvest in ${rec.crop.growthDurationDays} days',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '💡 ${rec.recommendationReason}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            rec.crop.waterLabel,
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                          InkWell(
                            onTap: () => vm.toggleCropSelection(rec.crop.id),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : AppColors.surfaceMuted,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected ? Icons.check_circle : Icons.add_circle_outline,
                                    size: 14,
                                    color: isSelected ? Colors.white : AppColors.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isSelected ? 'Selected' : 'Select',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.white : AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildLayoutGridTab(
    BuildContext context,
    PlannerViewModel vm,
    SpaceAnalysisResult? result,
  ) {
    if (result == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: const [
                Icon(Icons.sync_alt, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Companion Planting Grid: Green glowing borders denote symbiotic companion pairs (e.g., Tomato + Basil/Tulsi repels pests).',
                    style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Interactive Visual Grid
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.brown.shade100.withAlpha(120),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.brown.shade300, width: 2),
              ),
              child: Column(
                children: result.gridLayout.map((row) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: row.map((cell) {
                      return Container(
                        width: 86,
                        height: 86,
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: cell.hasCompanionSynergy
                                ? AppColors.accent
                                : Colors.grey.shade300,
                            width: cell.hasCompanionSynergy ? 2.5 : 1.0,
                          ),
                          boxShadow: [
                            if (cell.hasCompanionSynergy)
                              BoxShadow(
                                color: AppColors.accent.withAlpha(80),
                                blurRadius: 8,
                              ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(cell.crop?.emoji ?? '🪴', style: const TextStyle(fontSize: 26)),
                            const SizedBox(height: 2),
                            Text(
                              cell.crop?.name.split(' ').first ?? 'Pot',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (cell.hasCompanionSynergy)
                              const Text('✨ Companion', style: TextStyle(fontSize: 8, color: AppColors.primary, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Layout Spacing Tips:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 8),
          const Text('• Grow bags: Place taller plants (Tomato, Okra) toward the wall to prevent blocking sunlight for low herbs.'),
          const Text('• Air circulation: Leave at least 15cm between bags to prevent fungal mildew during Kerala monsoons.'),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildShoppingTab(
    BuildContext context,
    PlannerViewModel vm,
    SpaceAnalysisResult? result,
  ) {
    if (result == null) return const SizedBox.shrink();

    return StatefulBuilder(builder: (context, setTabState) {
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: result.nurseryShoppingList.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = result.nurseryShoppingList[index];
          return CheckboxListTile(
            value: item.isChecked,
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            tileColor: Colors.white,
            title: Text(
              item.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                decoration: item.isChecked ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Text(
              '${item.category} • Est: ${item.estimatedPriceKerala}\n💡 ${item.nurseryTip}',
              style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
            ),
            onChanged: (val) {
              setTabState(() {
                item.isChecked = val ?? false;
              });
            },
          );
        },
      );
    });
  }

  void _showStartFarmDialog(BuildContext context, PlannerViewModel vm) {
    final controller = TextEditingController(text: '${vm.selectedSpaceType.name.toUpperCase()} Garden');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Start Your Farm! 🌱'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Give your new urban garden a name:'),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: 'e.g. My Kochi Balcony'),
            ),
            const SizedBox(height: 12),
            Text(
              'Will plant ${vm.selectedCropIdsForFarm.length} recommended crops into your active dashboard.',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await vm.createFarmFromPlan(controller.text);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.primary,
                    content: Text('Farm "${controller.text}" created successfully! 🎉'),
                  ),
                );
                widget.onFarmCreated?.call();
              }
            },
            child: const Text('Create & Start Growing'),
          ),
        ],
      ),
    );
  }
}
