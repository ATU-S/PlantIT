import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plantit/core/theme/app_colors.dart';
import 'package:plantit/data/models/farm_model.dart';
import 'package:plantit/ui/view_models/farm_view_model.dart';
import 'package:plantit/ui/widgets/farm_crop_card.dart';
import 'package:plantit/ui/widgets/badge_unlock_dialog.dart';

class MyFarmScreen extends StatefulWidget {
  final VoidCallback onAddCropTap;

  const MyFarmScreen({super.key, required this.onAddCropTap});

  @override
  State<MyFarmScreen> createState() => _MyFarmScreenState();
}

class _MyFarmScreenState extends State<MyFarmScreen> {
  GrowthStage? _selectedFilterStage;

  @override
  Widget build(BuildContext context) {
    final farmVM = context.watch<FarmViewModel>();
    final activeFarm = farmVM.activeFarm;
    final allCrops = farmVM.activeCrops;

    final filteredCrops = _selectedFilterStage == null
        ? allCrops
        : allCrops.where((c) => c.stage == _selectedFilterStage).toList();

    return Scaffold(
      appBar: AppBar(
        title: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: activeFarm?.id,
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.primary,
            ),
            items: farmVM.farms.map((f) {
              return DropdownMenuItem<String>(
                value: f.id,
                child: Text(
                  f.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              );
            }).toList(),
            onChanged: (farmId) {
              if (farmId != null) farmVM.switchFarm(farmId);
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_location_alt_outlined,
              color: AppColors.primary,
            ),
            tooltip: 'Add New Space / Farm',
            onPressed: () => _showCreateFarmModal(context, farmVM),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All Crops'),
                  selected: _selectedFilterStage == null,
                  onSelected: (_) =>
                      setState(() => _selectedFilterStage = null),
                ),
                const SizedBox(width: 8),
                ...GrowthStage.values.map((stage) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(stage.name.toUpperCase()),
                      selected: _selectedFilterStage == stage,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilterStage = selected ? stage : null;
                        });
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          // Crops List
          Expanded(
            child: filteredCrops.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🌱', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        const Text(
                          'No crops match this filter',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ElevatedButton.icon(
                          onPressed: widget.onAddCropTap,
                          icon: const Icon(Icons.add),
                          label: const Text('Plant a New Crop'),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredCrops.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final crop = filteredCrops[index];
                      return FarmCropCard(
                        crop: crop,
                        onWater: () async {
                          final badges = await farmVM.waterCrop(crop.id);
                          if (context.mounted) {
                            for (final b in badges) {
                              BadgeUnlockDialog.show(context, b);
                            }
                          }
                        },
                        onHarvest: () async {
                          final badges = await farmVM.harvestCrop(crop.id);
                          if (context.mounted) {
                            for (final b in badges) {
                              BadgeUnlockDialog.show(context, b);
                            }
                          }
                        },
                        onTap: () =>
                            _showCropDetailSheet(context, farmVM, crop),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: widget.onAddCropTap,
        icon: const Icon(Icons.add),
        label: const Text('Add Crop'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _showCropDetailSheet(
    BuildContext context,
    FarmViewModel farmVM,
    FarmCrop crop,
  ) {
    final notesController = TextEditingController(text: crop.customNotes);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(crop.emoji, style: const TextStyle(fontSize: 36)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          crop.cropName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Planted on ${crop.plantedDate.day}/${crop.plantedDate.month}/${crop.plantedDate.year}',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'Update Growth Stage:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: GrowthStage.values.map((stage) {
                  final isCurrent = crop.stage == stage;
                  return ChoiceChip(
                    label: Text(stage.name),
                    selected: isCurrent,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isCurrent ? Colors.white : AppColors.textPrimary,
                      fontSize: 12,
                    ),
                    onSelected: (val) {
                      if (val) {
                        farmVM.updateStage(crop.id, stage);
                        Navigator.pop(ctx);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text(
                'Garden notes:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: notesController,
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Observations, feeding schedule, or pests spotted…',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Log care:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _careAction(
                    context,
                    farmVM,
                    crop,
                    ActivityType.fertilize,
                    Icons.compost,
                    'Fertilize +5',
                  ),
                  _careAction(
                    context,
                    farmVM,
                    crop,
                    ActivityType.prune,
                    Icons.content_cut,
                    'Prune +4',
                  ),
                  _careAction(
                    context,
                    farmVM,
                    crop,
                    ActivityType.pestControl,
                    Icons.shield_outlined,
                    'Pest control +6',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await farmVM.updateNotes(crop.id, notesController.text);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save Notes'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _careAction(
    BuildContext context,
    FarmViewModel farmVM,
    FarmCrop crop,
    ActivityType type,
    IconData icon,
    String label,
  ) {
    return OutlinedButton.icon(
      onPressed: () async {
        final badges = await farmVM.logCare(crop.id, type);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${type.name} logged for ${crop.cropName}. Great care!',
            ),
          ),
        );
        for (final badge in badges) {
          BadgeUnlockDialog.show(context, badge);
        }
      },
      icon: Icon(icon, size: 16),
      label: Text(label),
    );
  }

  void _showCreateFarmModal(BuildContext context, FarmViewModel farmVM) {
    final nameCtrl = TextEditingController(text: 'Kerala Rooftop Garden');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create New Garden Space'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Farm Name'),
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
              await farmVM.createNewFarm(
                name: nameCtrl.text,
                spaceType: 'Terrace',
                lengthMeters: 5.0,
                widthMeters: 3.0,
                sunlightHours: 6.0,
              );
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
