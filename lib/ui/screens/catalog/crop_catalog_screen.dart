import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plantit/core/theme/app_colors.dart';
import 'package:plantit/data/models/crop_model.dart';
import 'package:plantit/data/local/kerala_crop_catalog.dart';
import 'package:plantit/ui/view_models/farm_view_model.dart';
import 'package:plantit/ui/widgets/badge_unlock_dialog.dart';
import '../guide/plant_guide_screen.dart';

class CropCatalogScreen extends StatefulWidget {
  const CropCatalogScreen({super.key});

  @override
  State<CropCatalogScreen> createState() => _CropCatalogScreenState();
}

class _CropCatalogScreenState extends State<CropCatalogScreen> {
  String _searchQuery = '';
  CropCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final farmVM = context.watch<FarmViewModel>();
    List<Crop> displayedCrops = KeralaCropCatalog.search(_searchQuery);

    if (_selectedCategory != null) {
      displayedCrops = displayedCrops.where((c) => c.category == _selectedCategory).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kerala Crop Library 📚🌴'),
      ),
      body: Column(
        children: [
          // Search Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search crops in English or മലയാളം...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          // Category Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All Varieties'),
                  selected: _selectedCategory == null,
                  onSelected: (_) => setState(() => _selectedCategory = null),
                ),
                const SizedBox(width: 8),
                ...CropCategory.values.map((cat) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat.name.toUpperCase()),
                      selected: _selectedCategory == cat,
                      onSelected: (val) => setState(() => _selectedCategory = val ? cat : null),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Crop List
          Expanded(
            child: displayedCrops.isEmpty
                ? const Center(child: Text('No crops found matching search.'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: displayedCrops.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final crop = displayedCrops[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceMuted,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(crop.emoji, style: const TextStyle(fontSize: 26)),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  crop.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(20),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${crop.growthDurationDays}d',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${crop.malayalamName} • ${crop.scientificName}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(crop.lightLabel, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                  const SizedBox(width: 8),
                                  Text('• ${crop.difficultyLabel}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                ],
                              ),
                            ],
                          ),
                          onTap: () => _showCropDetails(context, farmVM, crop),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showCropDetails(BuildContext context, FarmViewModel farmVM, Crop crop) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (_, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(crop.emoji, style: const TextStyle(fontSize: 44)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              crop.name,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${crop.malayalamName} (${crop.scientificName})',
                              style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildDetailRow('☀️ Sunlight', crop.lightLabel),
                  _buildDetailRow('💧 Irrigation', crop.waterLabel),
                  _buildDetailRow('🗓️ Ideal Seasons', crop.idealSeasons.join(', ')),
                  _buildDetailRow('📏 Plant Spacing', '${crop.spacingCm} cm (Grow bag: ${crop.minContainerDepthInches}" min depth)'),
                  const SizedBox(height: 14),
                  const Text('🌿 Potting Soil Mix:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(crop.soilRequirements, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  const SizedBox(height: 14),
                  const Text('💡 Kerala Agronomy Care Tips:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(crop.careTips, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  const SizedBox(height: 14),
                  const Text('🧺 Harvest Guide:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(crop.harvestGuide, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  const SizedBox(height: 20),
                  // AI Growing Guide button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PlantGuideScreen(crop: crop),
                          ),
                        );
                      },
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('🤖 AI Growing Guide'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        final badges = await farmVM.plantCrop(crop.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.primary,
                              content: Text('Planted ${crop.name} in your garden! (+10 pts) 🌱'),
                            ),
                          );
                          for (final b in badges) {
                            BadgeUnlockDialog.show(context, b);
                          }
                        }
                      },
                      icon: const Icon(Icons.spa),
                      label: Text('Plant ${crop.name} in Garden (+10 pts)'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
