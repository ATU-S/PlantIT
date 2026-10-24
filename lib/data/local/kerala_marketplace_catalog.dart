import '../models/marketplace_model.dart';

class KeralaMarketplaceCatalog {
  static const List<NurseryVendor> vendors = [
    // ── ERNAKULAM / KOCHI ──────────────────────────────────────────────────
    NurseryVendor(
      id: 'krishibhavan_kochi_central',
      name: 'Ernakulam District Krishi Bhavan',
      malayalamName: 'എറണാകുളം ജില്ലാ കൃഷി ഭവൻ',
      category: VendorCategory.krishibhavanGovt,
      district: 'Ernakulam',
      locationArea: 'Tripunithura, Kochi',
      address: 'Krishi Bhavan Road, Tripunithura, Ernakulam, Kerala 682301',
      phoneNumber: '04842777111',
      whatsappNumber: null,
      rating: 4.5,
      reviewsCount: 182,
      availableCrops: ['cheera_red', 'thakkali', 'vendakka', 'pavakka', 'kanthari_mulaku'],
      featuredOfferings: [
        MarketplaceItem(title: 'Certified Vegetable Seedling Trays', priceEstimate: '₹25 - ₹60', unit: 'per tray'),
        MarketplaceItem(title: 'Subsidised Vermicompost', priceEstimate: '₹12', unit: 'per kg'),
        MarketplaceItem(title: 'Panchagavya Liquid', priceEstimate: '₹80', unit: 'per litre'),
        MarketplaceItem(title: 'Farm Advisory & Soil Testing', priceEstimate: 'Free', unit: 'per session'),
      ],
      operationalHours: 'Mon-Sat, 10:00 AM - 5:00 PM',
      isVerified: true,
    ),
    NurseryVendor(
      id: 'green_thumb_kalamassery',
      name: 'Green Thumb Organic Nursery',
      malayalamName: 'ഗ്രീൻ തംബ് ഓർഗാനിക് നഴ്‌സറി',
      category: VendorCategory.seedlings,
      district: 'Ernakulam',
      locationArea: 'Kalamassery',
      address: 'CUSAT Road Junction, Near FACT Colony, Kalamassery, Kochi 683104',
      phoneNumber: '9847123456',
      whatsappNumber: '9847123456',
      rating: 4.8,
      reviewsCount: 341,
      availableCrops: ['cheera_red', 'thakkali', 'kanthari_mulaku', 'curry_leaf', 'moringa'],
      featuredOfferings: [
        MarketplaceItem(title: 'Cheera Red Seedlings', priceEstimate: '₹5', unit: 'per seedling'),
        MarketplaceItem(title: 'Curry Leaf Saplings (Grafted)', priceEstimate: '₹80', unit: 'per plant'),
        MarketplaceItem(title: 'Bio-enriched Potting Mix', priceEstimate: '₹95', unit: 'per 5 kg bag'),
        MarketplaceItem(title: 'Grow Bags (12" x 12")', priceEstimate: '₹35', unit: 'each'),
      ],
      operationalHours: 'Daily 8:00 AM - 7:30 PM',
      isVerified: true,
    ),
    NurseryVendor(
      id: 'urban_farm_mart_kochi',
      name: 'Urban Farm Mart Kochi',
      malayalamName: 'അർബൻ ഫാം മാർട്ട്',
      category: VendorCategory.growBagsAndSoil,
      district: 'Ernakulam',
      locationArea: 'Edappally, Kochi',
      address: 'NH-66, Near Lulu Mall Junction, Edappally, Kochi 682024',
      phoneNumber: '9567234789',
      whatsappNumber: '9567234789',
      rating: 4.6,
      reviewsCount: 218,
      availableCrops: [],
      featuredOfferings: [
        MarketplaceItem(title: 'Premium Terrace Garden Kit (12 Bags + Soil)', priceEstimate: '₹1,299', unit: 'per kit'),
        MarketplaceItem(title: 'HDPE Grow Bags (25L)', priceEstimate: '₹65', unit: 'each'),
        MarketplaceItem(title: 'Cocopeat Brick (compressed)', priceEstimate: '₹45', unit: 'per brick'),
        MarketplaceItem(title: 'Vermicompost (certified organic)', priceEstimate: '₹18', unit: 'per kg'),
      ],
      operationalHours: 'Tue-Sun, 9:00 AM - 8:00 PM',
      isVerified: true,
    ),
    NurseryVendor(
      id: 'malabar_vermicompost_kochi',
      name: 'Malabar Organics Composting',
      malayalamName: 'മലബാർ ഓർഗാനിക്‌സ്',
      category: VendorCategory.organicCompost,
      district: 'Ernakulam',
      locationArea: 'Angamaly',
      address: 'Kunnathunadu Village, Angamaly, Ernakulam 683573',
      phoneNumber: '9446234112',
      whatsappNumber: '9446234112',
      rating: 4.7,
      reviewsCount: 127,
      availableCrops: [],
      featuredOfferings: [
        MarketplaceItem(title: 'Eisenia Fetida (Red Wigglers) Worm Starter Kit', priceEstimate: '₹350', unit: 'per pack (250g worms)'),
        MarketplaceItem(title: 'Vermicompost (bulk)', priceEstimate: '₹12', unit: 'per kg (min 10 kg)'),
        MarketplaceItem(title: 'Fish Amino Acid (Meen Amilam)', priceEstimate: '₹200', unit: 'per litre'),
        MarketplaceItem(title: 'Panchagavya + Dasapushpam Kit', priceEstimate: '₹150', unit: 'per kit'),
      ],
      operationalHours: 'Mon-Sat, 8:00 AM - 5:00 PM',
      isVerified: true,
    ),

    // ── THIRUVANANTHAPURAM ─────────────────────────────────────────────────
    NurseryVendor(
      id: 'kau_tvm_center',
      name: 'KAU Technology Transfer Centre, Vellayani',
      malayalamName: 'കേരള കാർഷിക സർവ്വകലാശാല ടെക്‌നോളജി ട്രാൻസ്ഫർ',
      category: VendorCategory.krishibhavanGovt,
      district: 'Thiruvananthapuram',
      locationArea: 'Vellayani',
      address: 'Vellayani Campus, KAU, Thiruvananthapuram, Kerala 695522',
      phoneNumber: '04712539540',
      whatsappNumber: null,
      rating: 4.9,
      reviewsCount: 489,
      availableCrops: ['cheera_red', 'thakkali', 'kanthari_mulaku', 'moringa', 'pavakka', 'vendakka'],
      featuredOfferings: [
        MarketplaceItem(title: 'KAU Certified High-Yield Tomato Seedlings', priceEstimate: '₹8', unit: 'per seedling'),
        MarketplaceItem(title: 'Hybrid Bitter Gourd Saplings', priceEstimate: '₹15', unit: 'per sapling'),
        MarketplaceItem(title: 'KAU Research Variety Seeds', priceEstimate: '₹30 - ₹80', unit: 'per packet'),
        MarketplaceItem(title: 'Organic Pest Management Workshop', priceEstimate: '₹200', unit: 'per session'),
      ],
      operationalHours: 'Mon-Sat, 9:00 AM - 4:30 PM',
      isVerified: true,
    ),
    NurseryVendor(
      id: 'natures_canvas_tvm',
      name: "Nature's Canvas Nursery",
      malayalamName: 'നേച്ചർ കാൻവാസ് നഴ്‌സറി',
      category: VendorCategory.seedlings,
      district: 'Thiruvananthapuram',
      locationArea: 'Peroorkada',
      address: 'Mannanthala - Peroorkada Rd, near Zion Church, Peroorkada, TVM 695005',
      phoneNumber: '9745123890',
      whatsappNumber: '9745123890',
      rating: 4.5,
      reviewsCount: 213,
      availableCrops: ['cheera_red', 'thakkali', 'kanthari_mulaku', 'curry_leaf'],
      featuredOfferings: [
        MarketplaceItem(title: 'Terrace Garden Starter Pack (Soil + 8 seedlings)', priceEstimate: '₹450', unit: 'per kit'),
        MarketplaceItem(title: 'Heritage Tomato Varieties', priceEstimate: '₹12', unit: 'per seedling'),
        MarketplaceItem(title: 'Balcony Herb Collection', priceEstimate: '₹280', unit: 'per 6-pack'),
      ],
      operationalHours: 'Daily 7:30 AM - 8:00 PM',
      isVerified: true,
    ),

    // ── KOZHIKODE ──────────────────────────────────────────────────────────
    NurseryVendor(
      id: 'farook_agri_kozhikode',
      name: 'Farook Agri Seed Centre',
      malayalamName: 'ഫാറൂഖ് അഗ്രി സീഡ് സെന്റർ',
      category: VendorCategory.seedsAndSaplings,
      district: 'Kozhikode',
      locationArea: 'Mavoor Road, Calicut',
      address: 'Near Vellimadukunnu Junction, Mavoor Road, Kozhikode 673004',
      phoneNumber: '9847567123',
      whatsappNumber: '9847567123',
      rating: 4.6,
      reviewsCount: 178,
      availableCrops: ['cheera_red', 'thakkali', 'kanthari_mulaku', 'vendakka', 'pavakka'],
      featuredOfferings: [
        MarketplaceItem(title: 'Certified Vegetable Seeds', priceEstimate: '₹20 - ₹60', unit: 'per packet'),
        MarketplaceItem(title: 'Malabar Special Pepper Vine (Kurumulaku)', priceEstimate: '₹65', unit: 'per plant'),
        MarketplaceItem(title: 'Medicinal Plant Bundle', priceEstimate: '₹350', unit: 'per 8-plant set'),
      ],
      operationalHours: 'Mon-Sat, 9:00 AM - 7:00 PM',
      isVerified: true,
    ),

    // ── THRISSUR ───────────────────────────────────────────────────────────
    NurseryVendor(
      id: 'thrissur_krishi_bhavan',
      name: 'Thrissur District Krishi Bhavan (Chavakkad Block)',
      malayalamName: 'തൃശ്ശൂർ ജില്ലാ കൃഷി ഭവൻ',
      category: VendorCategory.krishibhavanGovt,
      district: 'Thrissur',
      locationArea: 'Chavakkad',
      address: 'Block Development Office Campus, Chavakkad, Thrissur 680506',
      phoneNumber: '04872694011',
      whatsappNumber: null,
      rating: 4.4,
      reviewsCount: 94,
      availableCrops: ['cheera_red', 'thakkali', 'kanthari_mulaku', 'moringa'],
      featuredOfferings: [
        MarketplaceItem(title: 'Free Seedlings (for registered farmers)', priceEstimate: 'Free', unit: 'per season'),
        MarketplaceItem(title: 'Subsidised Bio-pesticide Kit', priceEstimate: '₹50', unit: 'per kit'),
      ],
      operationalHours: 'Mon-Sat, 10:00 AM - 4:30 PM',
      isVerified: true,
    ),
  ];

  /// Get vendors by district
  static List<NurseryVendor> getByDistrict(String district) =>
      vendors.where((v) => v.district.toLowerCase() == district.toLowerCase()).toList();

  /// Get vendors by category
  static List<NurseryVendor> getByCategory(VendorCategory category) =>
      vendors.where((v) => v.category == category).toList();

  /// Search vendors by keyword
  static List<NurseryVendor> search(String query) {
    final q = query.toLowerCase();
    return vendors.where((v) =>
      v.name.toLowerCase().contains(q) ||
      v.locationArea.toLowerCase().contains(q) ||
      v.district.toLowerCase().contains(q) ||
      v.featuredOfferings.any((o) => o.title.toLowerCase().contains(q))
    ).toList();
  }

  /// Get vendors who sell a specific crop
  static List<NurseryVendor> getForCrop(String cropId) =>
      vendors.where((v) => v.availableCrops.contains(cropId)).toList();

  static List<String> get allDistricts =>
      vendors.map((v) => v.district).toSet().toList()..sort();
}
