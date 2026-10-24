import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/local/local_storage_service.dart';
import 'data/repositories/crop_repository.dart';
import 'data/repositories/farm_repository.dart';
import 'data/repositories/gamification_repository.dart';
import 'domain/ai/space_vision_service.dart';
import 'domain/services/location_weather_service.dart';
import 'ui/view_models/farm_view_model.dart';
import 'ui/view_models/gamification_view_model.dart';
import 'ui/view_models/planner_view_model.dart';
import 'ui/screens/splash/splash_screen.dart';
import 'ui/screens/main_shell_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize offline-first local storage
  final storageService = await LocalStorageService.init();

  // Initialize data repositories
  final cropRepo = CropRepository();
  final farmRepo = FarmRepository(storageService);
  final gamificationRepo = GamificationRepository(storageService);

  // Initialize domain services
  final visionService = SpaceVisionService(
    geminiApiKey: storageService.getGeminiApiKey(),
  );

  runApp(
    PlantItApp(
      cropRepo: cropRepo,
      farmRepo: farmRepo,
      gamificationRepo: gamificationRepo,
      visionService: visionService,
    ),
  );
}

class PlantItApp extends StatelessWidget {
  final CropRepository cropRepo;
  final FarmRepository farmRepo;
  final GamificationRepository gamificationRepo;
  final SpaceVisionService visionService;

  const PlantItApp({
    super.key,
    required this.cropRepo,
    required this.farmRepo,
    required this.gamificationRepo,
    required this.visionService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<GamificationViewModel>(
          create: (_) => GamificationViewModel(repository: gamificationRepo),
        ),
        ChangeNotifierProxyProvider<GamificationViewModel, FarmViewModel>(
          create: (ctx) => FarmViewModel(
            farmRepository: farmRepo,
            gamificationViewModel: ctx.read<GamificationViewModel>(),
          ),
          update: (_, gamificationVM, farmVM) =>
              farmVM ??
              FarmViewModel(
                farmRepository: farmRepo,
                gamificationViewModel: gamificationVM,
              ),
        ),
        ChangeNotifierProxyProvider<FarmViewModel, PlannerViewModel>(
          create: (ctx) => PlannerViewModel(
            visionService: visionService,
            farmViewModel: ctx.read<FarmViewModel>(),
          ),
          update: (_, farmVM, plannerVM) =>
              plannerVM ??
              PlannerViewModel(
                visionService: visionService,
                farmViewModel: farmVM,
              ),
        ),
        // Live weather service (no API key needed – Open-Meteo)
        ChangeNotifierProvider<LocationWeatherService>(
          create: (_) => LocationWeatherService(),
        ),
      ],
      child: MaterialApp(
        title: 'PlantIT',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(
          nextScreen: MainShellScreen(),
        ),
      ),
    );
  }
}
