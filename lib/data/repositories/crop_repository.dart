import '../models/crop_model.dart';
import '../local/kerala_crop_catalog.dart';

class CropRepository {
  List<Crop> getAllCrops() {
    return KeralaCropCatalog.crops;
  }

  Crop? getCropById(String id) {
    return KeralaCropCatalog.getById(id);
  }

  List<Crop> searchCrops(String query) {
    return KeralaCropCatalog.search(query);
  }

  List<Crop> getCropsByCategory(CropCategory category) {
    return KeralaCropCatalog.crops.where((c) => c.category == category).toList();
  }
}
