import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plantit/data/local/local_storage_service.dart';
import 'package:plantit/data/repositories/crop_repository.dart';
import 'package:plantit/data/repositories/farm_repository.dart';
import 'package:plantit/data/repositories/gamification_repository.dart';
import 'package:plantit/domain/ai/space_vision_service.dart';
import 'package:plantit/main.dart';

void main() {
  testWidgets('PlantIT app boots up with Dashboard smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await LocalStorageService.init();
    final cropRepo = CropRepository();
    final farmRepo = FarmRepository(storage);
    final gamificationRepo = GamificationRepository(storage);
    final visionService = SpaceVisionService();

    await tester.pumpWidget(
      PlantItApp(
        cropRepo: cropRepo,
        farmRepo: farmRepo,
        gamificationRepo: gamificationRepo,
        visionService: visionService,
      ),
    );

    await tester.pumpAndSettle();

    // Verify main navigation bar elements
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('AI Planner'), findsOneWidget);
    expect(find.text('My Garden'), findsAtLeastNWidgets(1));
    expect(find.text('Crops'), findsOneWidget);
    expect(find.text('Trophies'), findsOneWidget);
  });
}
