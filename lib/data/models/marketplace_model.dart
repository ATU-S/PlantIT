enum VendorCategory {
  seedlings,
  seedsAndSaplings,
  growBagsAndSoil,
  organicCompost,
  krishibhavanGovt,
}

class MarketplaceItem {
  final String title;
  final String priceEstimate;
  final String unit;

  const MarketplaceItem({
    required this.title,
    required this.priceEstimate,
    required this.unit,
  });
}

class NurseryVendor {
  final String id;
  final String name;
  final String malayalamName;
  final VendorCategory category;
  final String district;
  final String locationArea;
  final String address;
  final String phoneNumber;
  final String? whatsappNumber;
  final double rating;
  final int reviewsCount;
  final bool isVerified;
  final List<String> availableCrops; // Crop IDs e.g. ['cheera_red', 'kanthari_mulaku']
  final List<MarketplaceItem> featuredOfferings;
  final String operationalHours;

  const NurseryVendor({
    required this.id,
    required this.name,
    required this.malayalamName,
    required this.category,
    required this.district,
    required this.locationArea,
    required this.address,
    required this.phoneNumber,
    this.whatsappNumber,
    required this.rating,
    required this.reviewsCount,
    this.isVerified = true,
    required this.availableCrops,
    required this.featuredOfferings,
    required this.operationalHours,
  });

  String get categoryLabel {
    switch (category) {
      case VendorCategory.seedlings:
        return '🌱 Nursery & Seedlings';
      case VendorCategory.seedsAndSaplings:
        return '🌾 Certified Seed Bank';
      case VendorCategory.growBagsAndSoil:
        return '🪴 Potting Mix & Grow Bags';
      case VendorCategory.organicCompost:
        return '🪱 Vermicompost & Fertilizers';
      case VendorCategory.krishibhavanGovt:
        return '🏛️ Govt Krishi Bhavan Hub';
    }
  }
}
