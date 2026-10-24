import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/local/local_storage_service.dart';
import '../main_shell_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final LocalStorageService storageService;

  const OnboardingScreen({
    super.key,
    required this.storageService,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final Map<String, String> _answers = {
    'space': 'Balcony',
    'sunlight': '4-6 hours',
    'experience': 'Beginner',
    'goal': 'Grow food',
  };

  final List<Map<String, String>> _spaceOptions = const [
    {'label': 'Balcony', 'detail': 'Small space with pots'},
    {'label': 'Terrace', 'detail': 'Larger open surface'},
    {'label': 'Indoor', 'detail': 'Window or indoor area'},
    {'label': 'Backyard', 'detail': 'Ground or raised bed'},
  ];

  final List<Map<String, String>> _sunOptions = const [
    {'label': '1-3 hours', 'detail': 'Minimal sun'},
    {'label': '4-6 hours', 'detail': 'Good for many greens'},
    {'label': '6+ hours', 'detail': 'Strong tropical sunlight'},
    {'label': 'Shade', 'detail': 'Low-light area'},
  ];

  final List<Map<String, String>> _experienceOptions = const [
    {'label': 'Beginner', 'detail': 'Need simple guidance'},
    {'label': 'Some experience', 'detail': 'I know basics'},
    {'label': 'Experienced', 'detail': 'Confident grower'},
  ];

  final List<Map<String, String>> _goalOptions = const [
    {'label': 'Grow food', 'detail': 'Vegetables and greens'},
    {'label': 'Home decor', 'detail': 'Flowers and foliage'},
    {'label': 'Easy plants', 'detail': 'Low effort and relaxing'},
    {'label': 'Learn gardening', 'detail': 'Build confidence'},
  ];

  bool _isSaving = false;

  Future<void> _completeOnboarding() async {
    setState(() => _isSaving = true);

    await widget.storageService.saveBeginnerProfile(_answers);

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShellScreen()),
    );
  }

  Widget _buildChoiceSection({
    required String title,
    required String subtitle,
    required List<Map<String, String>> options,
    required String field,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: options.map((option) {
              final label = option['label'] ?? '';
              final detail = option['detail'] ?? '';
              final selected = _answers[field] == label;

              return ChoiceChip(
                label: SizedBox(
                  width: 120,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        detail,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          color: selected
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                selected: selected,
                onSelected: (_) {
                  setState(() => _answers[field] = label);
                },
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.backgroundLight,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : AppColors.textPrimary,
                ),
                side: BorderSide(
                  color: selected ? AppColors.primary : Colors.grey.shade300,
                  width: 1.2,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to PlantIT',
                style: GoogleFonts.outfit(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Let’s set up your first Kerala-friendly garden plan.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),
              _buildChoiceSection(
                title: '1. Space type',
                subtitle: 'Where do you want to grow?',
                options: _spaceOptions,
                field: 'space',
              ),
              _buildChoiceSection(
                title: '2. Sunlight',
                subtitle: 'How much direct sun does the area get?',
                options: _sunOptions,
                field: 'sunlight',
              ),
              _buildChoiceSection(
                title: '3. Experience',
                subtitle: 'How confident are you with gardening?',
                options: _experienceOptions,
                field: 'experience',
              ),
              _buildChoiceSection(
                title: '4. Goal',
                subtitle: 'What do you want to grow?',
                options: _goalOptions,
                field: 'goal',
              ),
              const SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSaving ? null : _completeOnboarding,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.2,
                          ),
                        )
                      : const Text('Continue to my garden'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
